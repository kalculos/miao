///|
pub struct UdpOption(Int)

///|
let _UDP_OP_BROADCAST = 1

///|
let _UDP_OPT_EMPTY : UdpOption = UdpOption(0)

///|
pub fn UdpOption::new(broadcast? : Bool = false) -> UdpOption {
  let mut flags = 0
  if broadcast {
    flags = flags | _UDP_OP_BROADCAST
  }
  UdpOption(flags)
}

///|
pub fn UdpOption::broadcast(self : UdpOption) -> Bool {
  (self.0 & _UDP_OP_BROADCAST) != 0
}
