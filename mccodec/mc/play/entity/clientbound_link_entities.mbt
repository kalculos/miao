///|
/// Link Entities packet (0x5D)
/// Links entities together
struct LinkEntitiesS2C {
  attached_entity_id : Int // Attached entity
  holding_entity_id : Int // Holding entity
}
///|
impl @mc.Packet for LinkEntitiesS2C with clientbound(self) {
  true
}