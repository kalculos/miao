///|
/// Entity Event packet (0x1E)
/// Triggers entity status effect
pub(all) struct EntityEventS2C {
  entity_id : Int // Entity ID
  entity_status : Byte // Status ID
}

///|
pub impl @mc.Packet for EntityEventS2C with clientbound(_) {
  true
}
