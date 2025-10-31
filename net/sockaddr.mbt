///|
pub(all) struct SockAddr {
  inet : InetAddr
  port : UInt16
} derive(Hash, Eq) // todo show

///|
pub impl Show for SockAddr with output(self, logger) {
  match self.inet {
    IPv4(_) as iv4 => logger.write_string(iv4.to_string())
    IPv6(_) as iv6 => logger.write_string("[\{iv6.to_string()}]")
  }
  logger.write_char(':')
  logger.write_string(self.port.to_string())
}
