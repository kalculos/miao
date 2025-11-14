///|
/// Place Ghost Recipe packet (0x38)
/// Places ghost recipe items
pub(all) struct PlaceGhostRecipeS2C {
  window_id : Byte // Window ID
  recipe : String // Recipe identifier
}
///|
pub impl @mc.Packet for PlaceGhostRecipeS2C with clientbound(_) {
  true
}