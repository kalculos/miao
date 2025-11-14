///|
/// Update Entity Position and Rotation packet (0x2F)
/// Updates entity position and rotation
pub(all) struct UpdateEntityPositionAndRotationS2C {
  entity_id : Int // Entity ID
  delta_x : Int16 // X movement delta
  delta_y : Int16 // Y movement delta
  delta_z : Int16 // Z movement delta
  yaw : Byte // Yaw angle
  pitch : Byte // Pitch angle
  on_ground : Bool // On ground flag
}
///|
pub impl @mc.Packet for UpdateEntityPositionAndRotationS2C with clientbound(_) {
  true
}