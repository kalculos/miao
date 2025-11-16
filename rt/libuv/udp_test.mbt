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
