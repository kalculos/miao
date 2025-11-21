///|
/// A Channel usually backed by sockets, Its state could be mutated after invoking close() and does not guarantee thread safety.
pub(open) trait Connection: @io.Channel {
  local_addr(Self) -> SockAddr
  remote_addr(Self) -> SockAddr
  // a workaround for the lack of unsafe cast.
  unsafe_tcp_conn(Self) -> &TcpConnection = _
  unsafe_udp_conn(Self) -> &DatagramConnection = _
  // Flushes all the data to destination
  async flush(Self) -> Unit
}

///|
impl Connection with unsafe_tcp_conn(_) {
  abort("Unsupported operation on connection.")
}

///|
impl Connection with unsafe_udp_conn(_) {
  abort("Unsupported operation on connection.")
}
