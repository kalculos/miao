///|
/// A Channel usually backed by sockets, Its state could be mutated after invoking close() and does not guarantee thread safety.
pub(open) trait Connection: @io.Channel {
  local_addr(Self) -> SockAddr
  remote_addr(Self) -> SockAddr
  // Flushes all the data to destination
  async flush(Self) -> Unit
}
