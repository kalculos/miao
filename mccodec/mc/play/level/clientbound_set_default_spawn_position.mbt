///|
/// Set Default Spawn Position packet (0x5A)
/// Sets world spawn position
struct SetDefaultSpawnPositionS2C {
  location : (Int, Int, Int) // Spawn position
  angle : Float // Spawn angle
}
///|
impl @mc.Packet for SetDefaultSpawnPositionS2C with clientbound(self) {
  true
}