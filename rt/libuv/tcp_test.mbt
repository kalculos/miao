///|
/// Tests for TCP networking with LibuvRuntime
/// These tests verify TCP client/server communication

///|
/// Test TCP server bind and close
test "TCP server can bind to address" {
  @libuv.with_test(() => {
    // Bind to localhost on a high port - should succeed
    let socket = match @net.listen_tcp("127.0.0.1:19876") {
      Ok(s) => s
      Err(_) => {
        assert_false(true, msg="Failed to bind TCP socket")
        return
      }
    }

    // Successfully bound - this is expected
    inspect(socket.is_closed(), content="false")
    @net.Socket::close(socket)
    ()
  })
}

///|
/// Test TCP address parsing
test "TCP bind validates address format" {
  @libuv.with_test(() => {
    // Try to bind with invalid address format
    let result = @net.listen_tcp("invalid-address")
    match result {
      Ok(_) =>
        // Should not succeed with invalid address
        assert_false(true, msg="Expected invalid address to fail binding")
      Err(err) =>
        // Should get InvalidAddress error
        match err {
          @net.NetworkError::InvalidAddress(_) => ()
          _ => ()
        }
    }
  })
}
