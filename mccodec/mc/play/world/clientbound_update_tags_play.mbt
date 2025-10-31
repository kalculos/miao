///|
/// Update Tags (play) packet (0x7F)
/// Updates tag data
struct UpdateTagsPlayS2C {
  tags : Array[(String, Array[(String, Array[Int])])] // Registry tags
}
///|
impl @mc.Packet for UpdateTagsPlayS2C with clientbound(self) {
  true
}