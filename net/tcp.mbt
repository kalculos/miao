///|
pub struct TcpChannel {
  priv tcp : @socket.TCP
  priv mut closed : Bool
  priv remote_addr : @socket.Addr
  priv local_addr : @socket.Addr
}

///|
fn _close(self : TcpChannel) -> Unit {
  guard self.closed
  self.closed = true
  self.tcp.close()
}

///|
pub impl Connection for TcpChannel with remote_address(self) -> @socket.Addr {
  self.remote_addr
}

///|
pub impl Connection for TcpChannel with local_address(self) -> @socket.Addr {
  self.local_addr
}