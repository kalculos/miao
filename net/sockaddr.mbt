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
pub impl Show for SockAddr with output(self, logger) {
  match self.inet {
    IPv4(_) as iv4 => logger.write_string(iv4.to_string())
    IPv6(_) as iv6 => logger.write_string("[\{iv6.to_string()}]")
  }
  logger.write_char(':')
  logger.write_string(self.port.to_string())
}
