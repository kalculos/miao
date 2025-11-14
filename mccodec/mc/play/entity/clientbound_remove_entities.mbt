///|
/// Remove Entities packet (0x46)
/// Removes entities from world
pub(all) struct RemoveEntitiesS2C {
  entity_ids : Array[Int] // Entity IDs to remove
}
///|
pub impl @mc.Packet for RemoveEntitiesS2C with clientbound(_) {
  true
}