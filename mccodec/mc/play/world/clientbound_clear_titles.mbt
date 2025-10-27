///|
/// Clear Titles packet (0x0E)
/// Clears title display
struct ClearTitlesS2C {
  reset : Bool // Whether to reset title
}
///|
impl @mc.Packet for ClearTitlesS2C with clientbound(self) {
  true
}