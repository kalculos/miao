///|
/// Set Border Warning Delay packet (0x54)
/// Sets border warning delay
struct SetBorderWarningDelayS2C {
  warning_time : Int // Warning time in seconds
}
///|
impl @mc.Packet for SetBorderWarningDelayS2C with clientbound(self) {
  true
}