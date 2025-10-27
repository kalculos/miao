///|
/// Entity Animation packet (0x02)
/// Sent when an entity plays an animation
struct EntityAnimationS2C {
  entity_id : Int // Entity ID
  animation : Byte // Animation type
}
///|
impl @mc.Packet for EntityAnimationS2C with clientbound(self) {
  true
}