///|
/// Update Entity Rotation packet (0x31)
/// Updates entity rotation only
pub(all) struct UpdateEntityRotationS2C {
  entity_id : Int // Entity ID
  yaw : Byte // Yaw angle
  pitch : Byte // Pitch angle
  on_ground : Bool // On ground flag
}

///|
pub impl @mc.Packet for UpdateEntityRotationS2C with clientbound(_) {
  true
}
