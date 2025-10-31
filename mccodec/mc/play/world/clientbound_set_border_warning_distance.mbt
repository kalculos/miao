///|
/// Set Border Warning Distance packet (0x55)
/// Sets border warning distance
struct SetBorderWarningDistanceS2C {
  warning_blocks : Int // Warning distance in blocks
}
///|
impl @mc.Packet for SetBorderWarningDistanceS2C with clientbound(self) {
  true
}