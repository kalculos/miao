///|
/// Set Border Warning Delay packet (0x54)
/// Sets border warning delay
pub(all) struct SetBorderWarningDelayS2C {
  warning_time : Int // Warning time in seconds
}

///|
pub impl @mc.Packet for SetBorderWarningDelayS2C with clientbound(_) {
  true
}
