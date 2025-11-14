///|
/// Clear Titles packet (0x0E)
/// Clears title display
pub(all) struct ClearTitlesS2C {
  reset : Bool // Whether to reset title
}
///|
pub impl @mc.Packet for ClearTitlesS2C with clientbound(_) {
  true
}