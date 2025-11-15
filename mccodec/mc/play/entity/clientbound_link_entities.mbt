///|
/// Link Entities packet (0x5D)
/// Links entities together
pub(all) struct LinkEntitiesS2C {
  attached_entity_id : Int // Attached entity
  holding_entity_id : Int // Holding entity
}

///|
pub impl @mc.Packet for LinkEntitiesS2C with clientbound(_) {
  true
}
