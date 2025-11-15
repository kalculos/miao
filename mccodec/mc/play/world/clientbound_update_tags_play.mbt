///|
/// Update Tags (play) packet (0x7F)
/// Updates tag data
pub(all) struct UpdateTagsPlayS2C {
  tags : Array[(String, Array[(String, Array[Int])])] // Registry tags
}

///|
pub impl @mc.Packet for UpdateTagsPlayS2C with clientbound(_) {
  true
}
