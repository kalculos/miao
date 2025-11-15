///|
/// Set Border Warning Distance packet (0x55)
/// Sets border warning distance
pub(all) struct SetBorderWarningDistanceS2C {
  warning_blocks : Int // Warning distance in blocks
}

///|
pub impl @mc.Packet for SetBorderWarningDistanceS2C with clientbound(_) {
  true
}
