///|
/// Player Info Update packet (0x3F)
/// Updates player list info
struct PlayerInfoUpdateS2C {
  actions : Byte // Action flags
  players : Array[String] // Player data (complex structure)
}
///|
impl @mc.Packet for PlayerInfoUpdateS2C with clientbound(self) {
  true
}