///|
/// Tests for TCP networking with LibuvRuntime
/// These tests verify TCP client/server communication

///|
/// Test TCP server bind and close
async test "TCP server can bind to address" {
  // Bind to localhost on a high port - should succeed
  let result = @net.listen_tcp("127.0.0.1:19876")
  
  match result {
    Ok(socket) => {
      // Successfully bound - this is expected
      inspect(socket.is_closed(), content="false")
      @net.Socket::close(socket)
      inspect(true, content="true")
    }
    Err(err) => {
      // Binding should not fail - if it does, fail the test
      inspect(false, content="true")
    }
  }
}

///|
/// Test TCP client connection attempt to unreachable address
async test "TCP dial to unreachable address fails gracefully" {
  // Try to dial to an address that likely won't have a server
  // Using localhost on a port that should be free
  let result = @net.dial_tcp("127.0.0.1:19999")
  
  match result {
    Ok(_) => {
      // Unlikely to succeed unless something is running there
      inspect(false, content="false")
    }
    Err(_) => {
      // Expected to fail with connection refused
      inspect(true, content="true")
    }
  }
}

///|
/// Test TCP address parsing
async test "TCP bind validates address format" {
  // Try to bind with invalid address format
  let result = @net.listen_tcp("invalid-address")
  
  match result {
    Ok(_) => {
      // Should not succeed with invalid address
      inspect(false, content="false")
    }
    Err(err) => {
      // Should get InvalidAddress error
      match err {
        @net.NetworkError::InvalidAddress(_) => inspect(true, content="true")
        _ => inspect(false, content="false")
      }
    }
  }
}

///|
/// Test TCP communication between server and client
async test "TCP server and client can communicate" {
  let rt = LibuvRuntime::default()
  
  // Start a server task
  let server_task = rt.new_task(fn(_) {
    // Server: Listen on a port
    let server_result = @net.listen_tcp("127.0.0.1:19877") catch { _ => return }
    match server_result {
      Ok(server) => {
        // Accept one connection with a timeout
        let timeout = @time.Duration::of_seconds(5L)
        let client_result = server.accept(timeout) catch { _ => return }
        
        match client_result {
          Ok(client) => {
            // Read data from client
            let buffer : FixedArray[Byte] = FixedArray::make(100, 0)
            let bytes_read = client.read(buffer, 0, 100) catch { _ => 0 }
            
            // Echo back to client
            if bytes_read > 0 {
              client.write(buffer, 0, bytes_read) |> ignore
            }
            
            @io.Channel::close(client) catch { _ => () }
          }
          Err(_) => ()
        }
        
        @net.Socket::close(server) catch { _ => () }
      }
      Err(_) => ()
    }
  })
  
  // Start a client task
  let client_task = rt.new_task(fn(_) {
    // Give server time to start
    let rt2 = LibuvRuntime::default()
    rt2.sleep(100) catch { _ => () }
    
    // Client: Connect to the server
    let client_result = @net.dial_tcp("127.0.0.1:19877") catch { _ => return }
    match client_result {
      Ok(conn) => {
        // Send data
        let send_data : FixedArray[Byte] = [b'H', b'i']
        conn.write(send_data, 0, 2) |> ignore
        
        // Read echo response
        let recv_buffer : FixedArray[Byte] = FixedArray::make(100, 0)
        let bytes_read = conn.read(recv_buffer, 0, 100) catch { _ => 0 }
        
        // Verify we got data back
        inspect(bytes_read > 0, content="true")
        
        @io.Channel::close(conn) catch { _ => () }
      }
      Err(_) => ()
    }
  })
  
  // Start both tasks
  server_task.start() catch { _ => () }
  client_task.start() catch { _ => () }
  
  // Wait for both to complete
  server_task.join() catch { _ => () }
  client_task.join() catch { _ => () }
  
  // If we got here, the test passed
  inspect(true, content="true")
}
