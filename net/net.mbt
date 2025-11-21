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
  async bind(Self, network : String, bind : String, options : Int) -> Result[
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
  // a workaround: We cannot cast types even with assertions.
  unsafe_tcp_socket(Self) -> &TcpSocket = _
  unsafe_udp_socket(Self) -> &DatagramSocket = _
  is_closed(Self) -> Bool
}

///|
impl Socket with unsafe_tcp_socket(self) {
  abort("Unsupported operation called on socket.")
}

///|
impl Socket with unsafe_udp_socket(self) {
  abort("Unsupported operation called on socket.")
}

///|
pub(open) trait DatagramSocket: Socket {
  /// Return (socksAddr, truncated)
  async accept(Self, buffer : &@buffer.Buffer, timeout : @time.Duration) -> Result[
    (SockAddr, Int),
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
  async dial(Self, host : SockAddr, opt : TcpOption) -> Result[
    &TcpConnection,
    NetworkError,
  ]
  // gracefully close
  async close(Self) -> Unit
  // RST
  async close_immediately(Self) -> Unit
}

///|
/// The datagram connection focuses on end-to-end communication over UDP.
/// It automatically rejects any incoming packets that is not originated from
/// the destination, and sets destination for all outgoing packets.
/// 
/// When this is returned by accept, it implies a wrapper of a packet. Miao
/// does not track its state to make udp "Connections".
pub(open) trait DatagramConnection: Connection {
  socket(Self) -> &DatagramSocket
  buffer(Self) -> &@buffer.Buffer
}

///|
pub(open) trait TcpConnection: Connection {}
