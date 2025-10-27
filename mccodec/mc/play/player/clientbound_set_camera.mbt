///|
/// Set Camera packet (0x56)
/// Sets camera target entity
struct SetCameraS2C {
  camera_id : Int // Camera entity ID
}
///|
impl @mc.Packet for SetCameraS2C with clientbound(self) {
  true
}