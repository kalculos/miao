///|
/// Hurt Animation packet (0x24)
/// Plays hurt animation
pub(all) struct HurtAnimationS2C {
  entity_id : Int // Entity ID
  yaw : Float // Damage yaw direction
}
///|
pub impl @mc.Packet for HurtAnimationS2C with clientbound(_) {
  true
}