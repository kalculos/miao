///|
/// Combat Death packet (0x3D)
/// Player death in combat
pub(all) struct CombatDeathS2C {
  player_id : Int // Player entity ID
  message : String // Death message
}
///|
pub impl @mc.Packet for CombatDeathS2C with clientbound(_) {
  true
}