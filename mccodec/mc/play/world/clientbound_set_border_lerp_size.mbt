///|
/// Set Border Lerp Size packet (0x52)
/// Animates world border size change
struct SetBorderLerpSizeS2C {
  old_diameter : Double // Current diameter
  new_diameter : Double // New diameter
  speed : Int64 // Resize speed in milliseconds
}
///|
impl @mc.Packet for SetBorderLerpSizeS2C with clientbound(self) {
  true
}