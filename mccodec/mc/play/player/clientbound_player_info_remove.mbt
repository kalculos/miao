///|
/// Player Info Remove packet (0x3E)
/// Removes players from player list
pub(all) struct PlayerInfoRemoveS2C {
  player_uuids : Array[String] // Player UUIDs to remove
}
///|
pub impl @mc.Packet for PlayerInfoRemoveS2C with clientbound(_) {
  true
}