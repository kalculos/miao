///|
/// Set Default Spawn Position packet (0x5A)
/// Sets world spawn position
pub(all) struct SetDefaultSpawnPositionS2C {
  location : (Int, Int, Int) // Spawn position
  angle : Float // Spawn angle
}
///|
pub impl @mc.Packet for SetDefaultSpawnPositionS2C with clientbound(_) {
  true
}