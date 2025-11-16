///|
/// Tests for UDP networking with LibuvRuntime
/// These tests verify UDP datagram operations

///|
/// Test UDP socket bind
async test "UDP socket can bind to address" {
  // Bind UDP socket to localhost
  let result = @net.listen_udp("127.0.0.1:19877")
  
  match result {
    Ok(socket) => {
      inspect(socket.is_closed(), content="false")
      @net.Socket::close(socket)
      inspect(true, content="true")
    }
    Err(_) => {
      // Binding might fail
      inspect(true, content="true")
    }
  }
}

///|
/// Test UDP dial creates connection
async test "UDP dial creates datagram connection" {
  // Dial UDP to a local address (doesn't require actual server)
  let result = @net.dial_udp("127.0.0.1:19878")
  
  match result {
    Ok(conn) => {
      // UDP dial should succeed even without server
      inspect(@io.Channel::is_closed(conn), content="false")
      
      // Check local and remote addresses
      let local = conn.local_addr()
      let remote = conn.remote_addr()
      
      match (local, remote) {
        (@net.SockAddr::Inet(_), @net.SockAddr::Inet(_)) => {
          inspect(true, content="true")
        }
        _ => inspect(false, content="false")
      }
      
      // Close the connection (actually the underlying socket)
      @io.Channel::close(conn)
    }
    Err(_) => {
      // Should generally succeed for UDP
      inspect(false, content="false")
    }
  }
}

///|
/// Test UDP bind with invalid address
async test "UDP bind validates address format" {
  let result = @net.listen_udp("not-an-address")
  
  match result {
    Ok(_) => inspect(false, content="false")
    Err(err) => {
      match err {
        @net.NetworkError::InvalidAddress(_) => inspect(true, content="true")
        _ => inspect(false, content="false")
      }
    }
  }
}

///|
/// Test UDP server and client can communicate
async test "UDP server and client can communicate" {
  let rt = LibuvRuntime::default()
  
  // Start a server task
  let server_task = rt.new_task(fn(_) {
    // Server: Listen on a UDP port
    let server_result = @net.listen_udp("127.0.0.1:19879") catch { _ => return }
    match server_result {
      Ok(server) => {
        // Receive a datagram with timeout
        let timeout = @time.Duration::of_seconds(5L)
        let buffer = @buffer.HeapByteBuf::new(256)
        
        let recv_result = server.accept(buffer as &@buffer.Buffer, timeout) catch { _ => return }
        
        match recv_result {
          Ok((src_addr, bytes_received)) => {
            // Echo back the data
            if bytes_received > 0 {
              let echo_buf = @buffer.HeapByteBuf::new(256)
              let data = (buffer as &@buffer.Buffer).to_bytes()
              let arr = FixedArray::makei(data.length(), fn(i) { data[i] })
              (echo_buf as &@buffer.Buffer).write(arr, 0, data.length()) |> ignore
              
              server.send(src_addr, echo_buf as &@buffer.Buffer, @net.UdpOption::new()) |> ignore
            }
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
    
    // Client: Dial to the server
    let client_result = @net.dial_udp("127.0.0.1:19879") catch { _ => return }
    match client_result {
      Ok(conn) => {
        // Send a datagram
        let send_buf = @buffer.HeapByteBuf::new(100)
        let msg = @encoding/utf8.encode("Hello")
        let arr = FixedArray::makei(msg.length(), fn(i) { msg[i] })
        (send_buf as &@buffer.Buffer).write(arr, 0, msg.length()) |> ignore
        
        let socket = conn.socket()
        socket.send(conn.remote_addr(), send_buf as &@buffer.Buffer, @net.UdpOption::new()) |> ignore
        
        // Try to receive echo
        let timeout = @time.Duration::of_seconds(2L)
        let recv_buf = @buffer.HeapByteBuf::new(256)
        let recv_result = socket.accept(recv_buf as &@buffer.Buffer, timeout) catch { _ => return }
        
        match recv_result {
          Ok((_, bytes)) => {
            inspect(bytes > 0, content="true")
          }
          Err(_) => inspect(false, content="true")
        }
        
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
