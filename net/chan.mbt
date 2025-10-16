///|
/// A Channel usually backed by sockets, Its state could be mutated after invoking close() and does not guarantee thread safety.
pub(open) trait Connection: @miao.Channel {
  remote_address(Self) -> @socket.Addr
  local_address(Self) -> @socket.Addr
}