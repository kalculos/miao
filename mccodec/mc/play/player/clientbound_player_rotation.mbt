///|
/// Player Rotation packet (0x42)
/// Updates player rotation
pub(all) struct PlayerRotationS2C {
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}

///|
pub impl @mc.Packet for PlayerRotationS2C with clientbound(_) {
  true
}
