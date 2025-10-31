///|
/// Remove Entities packet (0x46)
/// Removes entities from world
struct RemoveEntitiesS2C {
  entity_ids : Array[Int] // Entity IDs to remove
}
///|
impl @mc.Packet for RemoveEntitiesS2C with clientbound(self) {
  true
}