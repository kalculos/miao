///|
impl Network for Unit with dial(_, _, _, _) {
  abort("Network not supported on this runtime")
}

///|
impl Network for Unit with bind(_, _, _, _) {
  abort("Network not supported on this runtime")
}

///|
let _network : Ref[&Network] = Ref::new(())

///|
pub fn set_network(network : &Network) -> Unit {
  _network.val = network
}

///|
pub async fn dial_tcp(
  address : String,
  opt? : TcpOption = _TCP_OPT_EMPTY,
) -> Result[&TcpConnection, NetworkError] {
  _network.val
  .dial("tcp", address, opt.0)
  .map(it => it.unsafe_tcp_conn())
}

///|
pub async fn dial_udp(
  address : String,
  opt? : UdpOption = _UDP_OPT_EMPTY,
) -> Result[&DatagramConnection, NetworkError] {
  _network.val
  .dial("udp", address, opt.0)
  .map(it => it.unsafe_udp_conn())
}

///|
pub async fn listen_tcp(
  address : String,
  opt? : TcpOption = _TCP_OPT_EMPTY,
) -> Result[&TcpSocket, NetworkError] {
  _network.val
  .bind("tcp", address, opt.0)
  .map(it => it.unsafe_tcp_socket())
}

///|
pub async fn listen_udp(
  address : String,
  opt? : UdpOption = _UDP_OPT_EMPTY,
) -> Result[&DatagramSocket, NetworkError] {
  _network.val
  .bind("udp", address, opt.0)
  .map(it => it.unsafe_udp_socket())
}