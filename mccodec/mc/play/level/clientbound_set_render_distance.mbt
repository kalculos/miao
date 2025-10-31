///|
/// Set Render Distance packet (0x58)
/// Sets client render distance
struct SetRenderDistanceS2C {
  view_distance : Int // View distance in chunks
}
///|
impl @mc.Packet for SetRenderDistanceS2C with clientbound(self) {
  true
}