///|
/// A Channel usually backed by sockets.
pub(open) trait Connection: @miao.Channel {
  remote_address(Self) -> @socket.Addr
  local_address(Self) -> @socket.Addr
}