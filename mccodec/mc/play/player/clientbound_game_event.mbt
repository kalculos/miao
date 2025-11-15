///|
/// Game Event packet (0x22)
/// Global game state change
pub(all) struct GameEventS2C {
  event : Byte // Event type
  value : Float // Event value
}

///|
pub impl @mc.Packet for GameEventS2C with clientbound(_) {
  true
}
