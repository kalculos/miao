///|
pub(all) suberror NetworkError {
  InvalidAddress(msg~ : String)
  DeviceFailure(msg~ : String)
  ConnReset(msg~ : String)
  ConnClose(msg~ : String)
  TimedOut(msg~ : String)
} derive(Show, Eq, Hash)

///|
/// A low-level interface for accessing network.
/// Users should not depend on this trait directly. Use @net.dialXXX instead!!
/// `dial` create a socket with a bound random address and connects to the destinated address.
/// 
/// `bind` create and bind a socket to the specified address. You may reuse this socket to 
/// connect somewhere else or listen for requests by invoking Socket#accept.
/// bind and dial are both sockets, but the first one isn't bound to a user-specified address, 
/// which discourages the use of listening incoming packets. and the next one bound to a specified address
/// which encourages listening for incoming packets.
///
/// The returned socket may varies in the network parameter.
///  - When the network is specified to be `tcp`, the returned socket must be TcpSocket.
///  - When the network is specified to be 'udp', the returned socket must be DatagramSocket.
pub(open) trait Network {
  async dial(Self, network : String, address : String, options : Int) -> Result[
    &Connection,
    NetworkError,
  ]
  async bind(Self, network : String, bind : String) -> Result[
    &Socket,
    NetworkError,
  ]
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
  async send(Self, dst : SockAddr, buffer : &@buffer.Buffer, opt : UdpOption) -> Result[
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
  socket(Self) -> &DatagramSocket
  buffer(Self) -> &@buffer.Buffer
}

///|
pub(open) trait TcpConnection: Connection {}
