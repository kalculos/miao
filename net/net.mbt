///|
pub(open) trait TcpServer {
  async accept(Self, timeout_millis? : UInt64) -> &Connection
  async close(Self) -> Unit
  options(Self) -> TcpOption
  is_closed(Self) -> Unit
}

pub(open) trait TcpClient {
  async connect(Self, target: SockAddr, timeout_millis?: UInt64) -> &Connection
  options(Self) -> TcpOption
}

///|
pub(open) trait DatagramSocket {
  async recv(Self, timeout_millis~ : UInt64) -> SockAddr
  async send(Self, target~: SockAddr, data~: &@buffer.ByteSlice) -> (Int, Int)
}
