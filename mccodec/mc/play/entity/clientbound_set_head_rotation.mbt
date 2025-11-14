///|
/// Set Head Rotation packet (0x4C)
/// Sets entity head rotation
pub(all) struct SetHeadRotationS2C {
  entity_id : Int // Entity ID
  head_yaw : Byte // Head yaw angle
}
///|
pub impl @mc.Packet for SetHeadRotationS2C with clientbound(_) {
  true
}