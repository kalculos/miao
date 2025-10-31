///|
/// Hurt Animation packet (0x24)
/// Plays hurt animation
struct HurtAnimationS2C {
  entity_id : Int // Entity ID
  yaw : Float // Damage yaw direction
}
///|
impl @mc.Packet for HurtAnimationS2C with clientbound(self) {
  true
}