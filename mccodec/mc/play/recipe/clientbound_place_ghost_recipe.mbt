///|
/// Place Ghost Recipe packet (0x38)
/// Places ghost recipe items
struct PlaceGhostRecipeS2C {
  window_id : Byte // Window ID
  recipe : String // Recipe identifier
}
///|
impl @mc.Packet for PlaceGhostRecipeS2C with clientbound(self) {
  true
}