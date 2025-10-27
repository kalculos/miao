///|
/// Set Border Center packet (0x51)
/// Sets world border center
struct SetBorderCenterS2C {
  x : Double // Center X
  z : Double // Center Z
}
///|
impl @mc.Packet for SetBorderCenterS2C with clientbound(self) {
  true
}