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

///|
pub impl @miao.Channel for TcpChannel with close(self) {
  self._close()
}

///|
pub impl @miao.Reader for TcpChannel with can_read(self) -> Bool {
  !self.closed
}

///|
pub impl @io.Reader for TcpChannel with read(
  self,
  arr,
  offset? = 0,
  max_len? = arr.length() - offset,
) -> Int {
  self.tcp.read(arr, offset~, max_len~)
}

///|
pub impl @miao.Writer for TcpChannel with can_write(self) -> Bool {
  !self.closed
}

///|
pub impl @miao.Writer for TcpChannel with close(self) {
  self._close()
}

///|
pub impl @miao.Reader for TcpChannel with close(self) {
  self._close()
}

///|
pub impl @io.Writer for TcpChannel with write_once(self, bytes, offset~, len~) -> Int {
  self.tcp.write_once(bytes, offset~, len~)
}
