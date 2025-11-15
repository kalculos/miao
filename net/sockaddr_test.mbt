///| Test for SockAddrIn::from_host_port utility

///|
test "ipv4 basic" {
  let sa = SockAddrIn::from_host_port("127.0.0.1", 8080)
  inspect(sa.addr.to_string(), content="127.0.0.1")
  inspect(sa.port, content="8080")
}

///|
test "ipv6 basic" {
  let sa = SockAddrIn::from_host_port("[::1]", 443)
  inspect(sa.addr.to_string(), content="0:0:0:0:0:0:0:1")
  inspect(sa.port, content="443")
}

///|
test "ipv6 no brackets" {
  let sa = SockAddrIn::from_host_port("2001:db8::1", 1234)
  inspect(sa.addr.to_string(), content="2001:db8:0:0:0:0:0:1")
  inspect(sa.port, content="1234")
}

///|
test "invalid ipv4" {
  try {
    let _ = SockAddrIn::from_host_port("256.0.0.1", 80)
    inspect(false, content="true") // Should not reach here
  } catch {
    err =>
      // Just verify error was raised - message contains file paths
      inspect(err.to_string().contains("256"), content="true")
  }
}

///|
test "invalid ipv6" {
  try {
    let _ = SockAddrIn::from_host_port("[::zz]", 80)
    inspect(false, content="true") // Should not reach here
  } catch {
    err =>
      // Just verify error was raised - message contains file paths
      inspect(err.to_string().contains("zz"), content="true")
  }
}
