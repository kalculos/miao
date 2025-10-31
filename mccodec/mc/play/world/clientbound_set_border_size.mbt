///|
/// Set Border Size packet (0x53)
/// Sets world border size instantly
struct SetBorderSizeS2C {
  diameter : Double // Border diameter
}
///|
impl @mc.Packet for SetBorderSizeS2C with clientbound(self) {
  true
}