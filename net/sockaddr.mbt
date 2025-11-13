///|
pub enum SockAddr {
  Inet(SockAddrIn)
  Local
  Unix
  File
  Unspec
} derive(Hash, Eq, Show)

///|
pub(all) struct SockAddrIn {
  inet : InetAddr
  port : UInt16
} derive(Hash, Eq)

///|
let ipv6_re : @regexp.Regexp = (try? @regexp.compile(
  "^\\[?([0-9a-fA-F:]+)\\]?$",
)).unwrap()

///|
/// Utility to construct SockAddr from host and port string, distinguishing IPv4/IPv6
pub fn from_host_port(host : String, port : UInt16) -> SockAddrIn raise {
  // Use regexp to check for IPv6 (contains ':', possibly brackets)
  let is_ipv6 = ipv6_re.execute(host).matched() || host.contains(":")
  let h = if host.has_prefix("[") && host.has_suffix("]") {
    host[1:host.length() - 1].to_string()
  } else {
    host
  }
  let inet = if is_ipv6 {
    InetAddr::from_ipv6(h) catch {
      err => raise err
    }
  } else {
    InetAddr::from_ipv4(host) catch {
      err => raise err
    }
  }
  SockAddrIn::{ inet, port }
}

///|
pub impl Show for SockAddrIn with output(self, logger) {
  match self.inet {
    IPv4(_) as iv4 => logger.write_string(iv4.to_string())
    IPv6(_) as iv6 => logger.write_string("[\{iv6.to_string()}]")
  }
  logger.write_char(':')
  logger.write_string(self.port.to_string())
}

///|
/// Parse address in format "host:port" or "[ipv6]:port"
pub fn SockAddrIn::parse(address : String) -> SockAddrIn raise {
  let parts = if address.has_prefix("[") {
    // IPv6 format [host]:port
    // Find the closing bracket by checking character by character
    let mut bracket_pos = -1
    let mut i = 1
    while i < address.length() {
      if address[i] == ']' {
        bracket_pos = i
        break
      }
      i += 1
    }
    guard bracket_pos > 0 else {
      raise fail("Invalid IPv6 address format: \{address}")
    }
    let host = address[1:bracket_pos].to_string()
    let port_str = address[bracket_pos + 2:].to_string()
    (host, port_str)
  } else {
    // IPv4 format host:port - find last colon
    let mut colon_pos = -1
    let mut i = address.length() - 1
    while i >= 0 {
      if address[i] == ':' {
        colon_pos = i
        break
      }
      i -= 1
    }
    guard colon_pos > 0 else {
      raise fail("Missing port in address: \{address}")
    }
    (address[0:colon_pos].to_string(), address[colon_pos + 1:].to_string())
  }
  let port = @strconv.parse_int(parts.1) catch {
    _ => raise fail("Invalid port: \{parts.1}")
  }
  guard port >= 0 && port <= 65535 else {
    raise fail("Port out of range: \{port}")
  }
  from_host_port(parts.0, port.to_uint16())
}

///|
pub fn SockAddrIn::to_string(self : SockAddrIn) -> String {
  // Use Show trait implementation via string interpolation
  "\{self}"
}
