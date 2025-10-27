///|
/// Player Rotation packet (0x42)
/// Updates player rotation
struct PlayerRotationS2C {
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}
///|
impl @mc.Packet for PlayerRotationS2C with clientbound(self) {
  true
}