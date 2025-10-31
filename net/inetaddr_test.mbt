///|
/// Tests forInetAddress::IPv4 parsing
test "from_ipv4 parses validInetAddress::IPv4 address" {
  let addr = InetAddress::from_ipv4("192.168.1.1")
  inspect(addr.to_string(), content="192.168.1.1")
}

///|
test "from_ipv4 parses 0.0.0.0" {
  let addr = InetAddress::from_ipv4("0.0.0.0")
  inspect(addr.to_string(), content="0.0.0.0")
}

///|
test "from_ipv4 parses 255.255.255.255" {
  let addr = InetAddress::from_ipv4("255.255.255.255")
  inspect(addr.to_string(), content="255.255.255.255")
}

///|
test "from_ipv4 parses 127.0.0.1" {
  let addr = InetAddress::from_ipv4("127.0.0.1")
  inspect(addr.to_string(), content="127.0.0.1")
}

///|
test "from_ipv4 parses 10.20.30.40" {
  let addr = InetAddress::from_ipv4("10.20.30.40")
  inspect(addr.to_string(), content="10.20.30.40")
}

///|
test "from_ipv4 fails on too few octets" {
  let result = try? InetAddress::from_ipv4("192.168.1")
  inspect(result is Err, content="true")
}

///|
test "from_ipv4 fails on too many octets" {
  let result = try? InetAddress::from_ipv4("192.168.1.1.1")
  inspect(result is Err, content="true")
}

///|
test "from_ipv4 fails on out of range octet (256)" {
  let result = try? InetAddress::from_ipv4("192.168.1.256")
  inspect(result is Err, content="true")
}

///|
test "from_ipv4 fails on negative octet" {
  let result = try? InetAddress::from_ipv4("192.168.-1.1")
  inspect(result is Err, content="true")
}

///|
test "from_ipv4 fails on non-numeric octet" {
  let result = try? InetAddress::from_ipv4("192.168.abc.1")
  inspect(result is Err, content="true")
}

///|
test "from_ipv4 fails on empty string" {
  let result = try? InetAddress::from_ipv4("")
  inspect(result is Err, content="true")
}

///|
test "from_ipv4 fails on leading zeros causing overflow" {
  let result = try? InetAddress::from_ipv4("192.168.001.1")
  inspect(result is Ok, content="true")
  match result {
    Ok(addr) => inspect(addr.to_string(), content="192.168.1.1")
    _ => ()
  }
}

///|
/// Tests forInetAddress::IPv6 parsing
test "from_ipv6 parses valid fullInetAddress::IPv6 address" {
  let addr = InetAddress::from_ipv6("2001:0db8:85a3:0000:0000:8a2e:0370:7334")
  inspect(addr.to_string(), content="2001:db8:85a3:0:0:8a2e:370:7334")
}

///|
test "from_ipv6 parses all zeros" {
  let addr = InetAddress::from_ipv6("0000:0000:0000:0000:0000:0000:0000:0000")
  inspect(addr.to_string(), content="0:0:0:0:0:0:0:0")
}

///|
test "from_ipv6 parses all ones (ffff)" {
  let addr = InetAddress::from_ipv6("ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")
  inspect(addr.to_string(), content="ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")
}

///|
test "from_ipv6 parses loopback address" {
  let addr = InetAddress::from_ipv6("0000:0000:0000:0000:0000:0000:0000:0001")
  inspect(addr.to_string(), content="0:0:0:0:0:0:0:1")
}

///|
test "from_ipv6 parses mixed case hex" {
  let addr = InetAddress::from_ipv6("2001:0DB8:85A3:0000:0000:8A2E:0370:7334")
  inspect(addr.to_string(), content="2001:db8:85a3:0:0:8a2e:370:7334")
}

///|
test "from_ipv6 fails on too few groups" {
  let result = try? InetAddress::from_ipv6("2001:0db8:85a3:0000:0000:8a2e:0370")
  inspect(result is Err, content="true")
}

///|
test "from_ipv6 fails on too many groups" {
  let result = try? InetAddress::from_ipv6(
      "2001:0db8:85a3:0000:0000:8a2e:0370:7334:1111",
    )
  inspect(result is Err, content="true")
}

///|
test "from_ipv6 fails on out of range hex (10000)" {
  let result = try? InetAddress::from_ipv6(
      "2001:0db8:85a3:10000:0000:8a2e:0370:7334",
    )
  inspect(result is Err, content="true")
}

///|
test "from_ipv6 fails on invalid hex characters" {
  let result = try? InetAddress::from_ipv6(
      "2001:0db8:85g3:0000:0000:8a2e:0370:7334",
    )
  inspect(result is Err, content="true")
}

///|
test "from_ipv6 fails on negative hex" {
  let result = try? InetAddress::from_ipv6(
      "2001:0db8:-85a3:0000:0000:8a2e:0370:7334",
    )
  inspect(result is Err, content="true")
}

///|
/// Tests for to_string output formatting
test "IPv4 to_string formats single digits correctly" {
  let addr = InetAddress::IPv4(host=0x01020304)
  inspect(addr.to_string(), content="1.2.3.4")
}

///|
test "IPv4 to_string handles all zero bytes" {
  let addr = InetAddress::IPv4(host=0)
  inspect(addr.to_string(), content="0.0.0.0")
}

///|
test "IPv4 to_string handles all 255 bytes" {
  let addr = InetAddress::IPv4(host=0xFFFFFFFF)
  inspect(addr.to_string(), content="255.255.255.255")
}

///|
test "IPv6 to_string formats with lowercase hex" {
  let addr = InetAddress::IPv6(
    msb=0xABCD_DEAD_BEEF_CAFE,
    lsb=0xFACE_B00C_C0DE_F00D,
  )
  let str = addr.to_string()
  inspect(str.contains("ABCD"), content="false")
  inspect(str.contains("abcd"), content="true")
}

///|
test "IPv6 to_string handles zero groups" {
  let addr = InetAddress::IPv6(msb=0, lsb=0)
  inspect(addr.to_string(), content="0:0:0:0:0:0:0:0")
}

///|
/// Tests for int64_to_hex helper
test "int64_to_hex converts 0" {
  inspect(int64_to_hex(0L), content="0")
}

///|
test "int64_to_hex converts single digit" {
  inspect(int64_to_hex(5L), content="5")
}

///|
test "int64_to_hex converts hex A-F" {
  inspect(int64_to_hex(10L), content="A")
  inspect(int64_to_hex(15L), content="F")
}

///|
test "int64_to_hex converts multi-digit numbers" {
  inspect(int64_to_hex(255L), content="FF")
  inspect(int64_to_hex(4096L), content="1000")
}

///|
test "int64_to_hex converts 0xFFFF" {
  inspect(int64_to_hex(0xFFFFL), content="FFFF")
}

///|
test "int64_to_hex converts large number" {
  inspect(int64_to_hex(0xDEADBEEFL), content="DEADBEEF")
}

///|
/// Round-trip tests
test "IPv4 round-trip through string" {
  let original = "192.168.1.100"
  let addr = InetAddress::from_ipv4(original)
  let back = addr.to_string()
  inspect(back, content="192.168.1.100")
}

///|
test "IPv4 round-trip with leading zeros normalized" {
  let addr = InetAddress::from_ipv4("010.020.030.040")
  inspect(addr.to_string(), content="10.20.30.40")
}

///|
test "IPv6 round-trip through string" {
  let addr = InetAddress::from_ipv6("2001:0db8:0000:0042:0000:8a2e:0370:7334")
  let str = addr.to_string()
  inspect(str, content="2001:db8:0:42:0:8a2e:370:7334")
}

///|
test "IPv6 round-trip preserves all bits" {
  let original = InetAddress::from_ipv6(
    "1234:5678:9abc:def0:fedc:ba98:7654:3210",
  )
  let str = original.to_string()
  let reparsed = InetAddress::from_ipv6(str)
  match (original, reparsed) {
    (InetAddress::IPv6 as a, InetAddress::IPv6(msb~, lsb~)) => {
      inspect(msb == a.msb, content="true")
      inspect(lsb == a.lsb, content="true")
    }
    _ => abort("ExpectedInetAddress::IPv6 addresses")
  }
}

///|
/// Edge cases and special addresses
test "IPv4 broadcast address" {
  let addr = InetAddress::from_ipv4("255.255.255.255")
  match addr {
    InetAddress::IPv4(host~) => inspect(host, content="-1")
    _ => abort("ExpectedInetAddress::IPv4")
  }
}

///|
test "IPv4 localhost" {
  let addr = InetAddress::from_ipv4("127.0.0.1")
  inspect(addr.to_string(), content="127.0.0.1")
}

///|
test "IPv4 private network 10.0.0.0" {
  let addr = InetAddress::from_ipv4("10.0.0.0")
  inspect(addr.to_string(), content="10.0.0.0")
}

///|
test "IPv4 private network 172.16.0.0" {
  let addr = InetAddress::from_ipv4("172.16.0.0")
  inspect(addr.to_string(), content="172.16.0.0")
}

///|
test "IPv4 private network 192.168.0.0" {
  let addr = InetAddress::from_ipv4("192.168.0.0")
  inspect(addr.to_string(), content="192.168.0.0")
}

///|
test "IPv6 multicast address" {
  let addr = InetAddress::from_ipv6("ff02:0000:0000:0000:0000:0000:0000:0001")
  inspect(addr.to_string(), content="ff02:0:0:0:0:0:0:1")
}

///|
test "InetAddress enum pattern matchingInetAddress::IPv4" {
  let addr = InetAddress::from_ipv4("1.2.3.4")
  match addr {
    InetAddress::IPv4(_) => inspect(true, content="true")
    InetAddress::IPv6 => inspect(false, content="true")
  }
}

///|
test "InetAddress enum pattern matchingInetAddress::IPv6" {
  let addr = InetAddress::from_ipv6("::1")
  match addr {
    InetAddress::IPv4(_) => inspect(false, content="true")
    InetAddress::IPv6 => inspect(true, content="true")
  }
}
