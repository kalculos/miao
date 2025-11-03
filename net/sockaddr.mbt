///|
pub(all) struct SockAddr {
  inet : InetAddr
  port : UInt16
} derive(Hash, Eq) // todo show

///|
let ipv6_re : @regexp.Regexp = (try? @regexp.compile(
  "^\\[?([0-9a-fA-F:]+)\\]?$",
)).unwrap()

///|
/// Utility to construct SockAddr from host and port string, distinguishing IPv4/IPv6
pub fn from_host_port(host : String, port : UInt16) -> SockAddr raise {
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
  SockAddr::{ inet, port }
}

///|
/// Parse address in format "host:port" or "[ipv6]:port"
pub fn SockAddr::parse(address : String) -> SockAddr raise {
  let parts = if address.has_prefix("[") {
    // IPv6 format [host]:port
    match address.index_of("]") {
      Some(end_bracket) => {
        let host = address[1:end_bracket].to_string()
        let port_str = address[end_bracket + 2:].to_string()
        (host, port_str)
      }
      None => raise fail("Invalid IPv6 address format: \{address}")
    }
  } else {
    // IPv4 format host:port
    match address.last_index_of(":") {
      Some(colon_idx) => (address[0:colon_idx].to_string(), address[colon_idx + 1:].to_string())
      None => raise fail("Missing port in address: \{address}")
    }
  }
  let port = try @strconv.parse_int(parts.1) catch {
    _ => raise fail("Invalid port: \{parts.1}")
  }
  guard port >= 0 && port <= 65535 else {
    raise fail("Port out of range: \{port}")
  }
  from_host_port(parts.0, port.to_uint16())
}

///|
pub fn SockAddr::to_string(self : SockAddr) -> String {
  // Use Show trait implementation via string interpolation
  "\{self}"
}

///|
pub impl Show for SockAddr with output(self, logger) {
  match self.inet {
    IPv4(_) as iv4 => logger.write_string(iv4.to_string())
    IPv6(_) as iv6 => logger.write_string("[\{iv6.to_string()}]")
  }
  logger.write_char(':')
  logger.write_string(self.port.to_string())
}
