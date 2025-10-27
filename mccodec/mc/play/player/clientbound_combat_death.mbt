///|
/// Combat Death packet (0x3D)
/// Player death in combat
struct CombatDeathS2C {
  player_id : Int // Player entity ID
  message : String // Death message
}
///|
impl @mc.Packet for CombatDeathS2C with clientbound(self) {
  true
}