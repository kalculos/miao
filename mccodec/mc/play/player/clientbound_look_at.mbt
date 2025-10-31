///|
/// Look At packet (0x40)
/// Makes player look at target
struct LookAtS2C {
  feet_eyes : Int // Anchor point
  target_x : Double // Target X
  target_y : Double // Target Y
  target_z : Double // Target Z
  is_entity : Bool // Whether target is entity
  entity_id : Int? // Entity ID (if is_entity)
  entity_anchor : Int? // Entity anchor point (if is_entity)
}
///|
impl @mc.Packet for LookAtS2C with clientbound(self) {
  true
}