///|
/// Player Info Update packet (0x3F)
/// Updates player list info
pub(all) struct PlayerInfoUpdateS2C {
  actions : Byte // Action flags
  players : Array[String] // Player data (complex structure)
}

///|
pub impl @mc.Packet for PlayerInfoUpdateS2C with clientbound(_) {
  true
}
