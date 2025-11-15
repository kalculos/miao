///|
/// Set Border Center packet (0x51)
/// Sets world border center
pub(all) struct SetBorderCenterS2C {
  x : Double // Center X
  z : Double // Center Z
}

///|
pub impl @mc.Packet for SetBorderCenterS2C with clientbound(_) {
  true
}
