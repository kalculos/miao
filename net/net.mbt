///|
pub(all) suberror NetworkError {
  InvalidAddress(msg~ : String)
  DeviceFailure(msg~ : String)
  ConnReset(msg~ : String)
  ConnClose(msg~ : String)
  TimedOut(msg~ : String)
} derive(Show, Eq, Hash)

///|
pub(open) trait Network {
  async dial(network : String, address : String, options : Int) -> Result[
    &Connection,
    NetworkError,
  ]
  async bind(network : String, bind : String) -> Result[&Socket, NetworkError]
}

///|
pub(open) trait Socket {
  async accept(Self, timeout : @time.Duration) -> Result[
    &Connection,
    NetworkError,
  ]
  async close(Self) -> Unit
  is_closed(Self) -> Bool
}

///|
pub(open) trait DatagramSocket: Socket {
  async accept(Self, timeout : @time.Duration) -> Result[
    &DatagramConnection,
    NetworkError,
  ]
  async send(Self, dst : SockAddr, opt : UdpOption) -> Result[
    Unit,
    NetworkError,
  ]
}

///|
pub(open) trait TcpSocket: Socket {
  async accept(Self, timeout : @time.Duration, opt? : TcpOption) -> Result[
    &TcpConnection,
    NetworkError,
  ]
  async dial(host : SockAddr, opt : TcpOption) -> Result[
    &TcpConnection,
    NetworkError,
  ]
}

///|
pub(open) trait DatagramConnection: Connection {
  buffer(Self) -> &@buffer.Buffer
}

///|
pub(open) trait TcpConnection: Connection {}
