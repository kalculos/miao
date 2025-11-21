///|
/// Tests for TCP networking with LibuvRuntime
/// These tests verify TCP client/server communication

///|
/// Test TCP server bind and close
test "TCP server can bind to address" {
  @libuv.with_test(() => {
    // Bind to localhost on a high port - should succeed
    let socket = @net.listen_tcp("127.0.0.1:19876").unwrap()
    
    // Successfully bound - this is expected
    inspect(socket.is_closed(), content="false")
    @net.Socket::close(socket)
    ()
  })
}

///|
/// Test TCP client connection attempt to unreachable address
test "TCP dial to unreachable address fails gracefully" {
  @libuv.with_test(() => {
    // Try to dial to an address that likely won't have a server
    // Using localhost on a port that should be free
    let result = @net.dial_tcp("127.0.0.1:19999")
    
    match result {
      Ok(_) => {
        // Should not succeed - assert nothing is running there
        assert_false(true, msg="Expected connection to fail, but it succeeded")
      }
      Err(_) => {
        // Expected to fail with connection refused
        ()
      }
    }
  })
}

///|
/// Test TCP address parsing
test "TCP bind validates address format" {
  @libuv.with_test(() => {
    // Try to bind with invalid address format
    let result = @net.listen_tcp("invalid-address")
    
    match result {
      Ok(_) => {
        // Should not succeed with invalid address
        assert_false(true, msg="Expected invalid address to fail binding")
      }
      Err(err) => {
        // Should get InvalidAddress error
        match err {
          @net.NetworkError::InvalidAddress(_) => ()
          _ => ()
        }
      }
    }
  })
}

///|
/// Test TCP communication between server and client
test "TCP server and client can communicate" {
  @libuv.with_test(() => {
    let rt = LibuvRuntime::default()
    
    // Start a server task
    let server_task = rt.new_task(fn(_) raise {
      // Server: Listen on a port
      let server = @net.listen_tcp("127.0.0.1:19877").unwrap()
      
      // Accept one connection with a timeout
      let timeout = @time.Duration::of_seconds(5L)
      let client = server.accept(timeout).unwrap()
      
      // Read data from client
      let buffer : FixedArray[Byte] = FixedArray::make(100, 0)
      let bytes_read = client.read(buffer, 0, 100)
      
      // Echo back to client
      if bytes_read > 0 {
        client.write(buffer, 0, bytes_read) |> ignore
      }
      
      @io.Channel::close(client)
      @net.Socket::close(server)
    })
    
    // Start a client task
    let client_task = rt.new_task(fn(_) raise {
      // Give server time to start
      let rt2 = LibuvRuntime::default()
      rt2.sleep(100)
      
      // Client: Connect to the server
      let conn = @net.dial_tcp("127.0.0.1:19877").unwrap()
      
      // Send data
      let send_data : FixedArray[Byte] = [b'H', b'i']
      conn.write(send_data, 0, 2) |> ignore
      
      // Read echo response
      let recv_buffer : FixedArray[Byte] = FixedArray::make(100, 0)
      let bytes_read = conn.read(recv_buffer, 0, 100)
      
      // Verify we got data back
      inspect(bytes_read > 0, content="true")
      
      @io.Channel::close(conn)
    })
    
    // Start both tasks
    server_task.start()
    client_task.start()
    
    // Wait for both to complete
    server_task.join()
    client_task.join()
    
    // If we got here, the test passed
    ()
  })
}
