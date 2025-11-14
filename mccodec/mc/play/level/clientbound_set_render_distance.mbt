///|
/// Set Render Distance packet (0x58)
/// Sets client render distance
pub(all) struct SetRenderDistanceS2C {
  view_distance : Int // View distance in chunks
}
///|
pub impl @mc.Packet for SetRenderDistanceS2C with clientbound(_) {
  true
}