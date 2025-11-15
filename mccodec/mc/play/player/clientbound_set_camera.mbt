///|
/// Set Camera packet (0x56)
/// Sets camera target entity
pub(all) struct SetCameraS2C {
  camera_id : Int // Camera entity ID
}

///|
pub impl @mc.Packet for SetCameraS2C with clientbound(_) {
  true
}
