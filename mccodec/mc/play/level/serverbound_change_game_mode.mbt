///|
/// Change Game Mode packet (0x04)
/// Requests game mode change (creative mode only)
pub(all) struct ChangeGameModeC2S {
  game_mode : Int // Requested game mode, TODO: enum
}

///|
pub impl @mc.Packet for ChangeGameModeC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ChangeGameModeC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.game_mode)
}

///|
pub impl @mc.Packet for ChangeGameModeC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { game_mode: @types.read_varint(buf) }
}

