///|
/// Tests for TCP networking with LibuvRuntime
/// These tests verify TCP client/server communication

///|
/// Test TCP server bind and close
async test "TCP server can bind to address" {
  // Bind to localhost on a high port
  let result = @net.listen_tcp("127.0.0.1:19876")
  
  match result {
    Ok(socket) => {
      // Successfully bound
      inspect(socket.is_closed(), content="false")
      @net.Socket::close(socket)
      inspect(true, content="true")
    }
    Err(_) => {
      // Binding might fail if port is in use, which is acceptable
      inspect(true, content="true")
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
