///|
/// Entity Event packet (0x1E)
/// Triggers entity status effect
struct EntityEventS2C {
  entity_id : Int // Entity ID
  entity_status : Byte // Status ID
}
///|
impl @mc.Packet for EntityEventS2C with clientbound(self) {
  true
}