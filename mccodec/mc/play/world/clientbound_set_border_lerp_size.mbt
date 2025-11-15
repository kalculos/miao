///|
/// Set Border Lerp Size packet (0x52)
/// Animates world border size change
pub(all) struct SetBorderLerpSizeS2C {
  old_diameter : Double // Current diameter
  new_diameter : Double // New diameter
  speed : Int64 // Resize speed in milliseconds
}

///|
pub impl @mc.Packet for SetBorderLerpSizeS2C with clientbound(_) {
  true
}
