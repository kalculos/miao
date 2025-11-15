///|
/// Update Attributes packet (0x7C)
/// Updates entity attributes
pub(all) struct UpdateAttributesS2C {
  entity_id : Int // Entity ID
  attributes : Array[(String, Double, Array[(String, String, Double, Int)])] // Attribute data
}

///|
pub impl @mc.Packet for UpdateAttributesS2C with clientbound(_) {
  true
}
