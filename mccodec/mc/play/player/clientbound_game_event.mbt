///|
/// Game Event packet (0x22)
/// Global game state change
struct GameEventS2C {
  event : Byte // Event type
  value : Float // Event value
}
///|
impl @mc.Packet for GameEventS2C with clientbound(self) {
  true
}