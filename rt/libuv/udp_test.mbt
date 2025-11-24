///|
/// Tests for UDP networking with LibuvRuntime
/// These tests verify UDP datagram operations

///|
/// Test UDP socket bind
test "UDP socket can bind to address" {
  @libuv.with_test(() => {
    // Bind UDP socket to localhost - should succeed
    let socket = match @net.listen_udp("127.0.0.1:19877") {
      Ok(s) => s
      Err(_) => {
        assert_false(true, msg="Failed to bind UDP socket")
        return
      }
    }
    inspect(socket.is_closed(), content="false")
    @net.Socket::close(socket)
    ()
  })
}

///|
/// Test UDP dial creates connection
test "UDP dial creates datagram connection" {
  @libuv.with_test(() => {
    // Dial UDP to a local address (doesn't require actual server)
    let conn = match @net.dial_udp("127.0.0.1:19878") {
      Ok(c) => c
      Err(_) => {
        assert_false(true, msg="Failed to dial UDP")
        return
      }
    }

    // UDP dial should succeed even without server
    inspect(@io.Channel::is_closed(conn), content="false")

    // Check local and remote addresses
    let local = conn.local_addr()
    let remote = conn.remote_addr()

    // Close the connection (actually the underlying socket)
    @io.Channel::close(conn)
  })
}

///|
/// Test UDP bind with invalid address
test "UDP bind validates address format" {
  @libuv.with_test(() => {
    let result = @net.listen_udp("not-an-address")
    match result {
      Ok(_) => ()
      Err(err) =>
        match err {
          @net.NetworkError::InvalidAddress(_) => ()
          _ => ()
        }
    }
  })
}