///|
/// Set Border Size packet (0x53)
/// Sets world border size instantly
pub(all) struct SetBorderSizeS2C {
  diameter : Double // Border diameter
}
///|
pub impl @mc.Packet for SetBorderSizeS2C with clientbound(_) {
  true
}