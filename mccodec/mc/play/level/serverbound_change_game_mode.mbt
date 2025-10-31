///|
/// Change Game Mode packet (0x04)
/// Requests game mode change (creative mode only)
struct ChangeGameModeC2S {
  game_mode : Int // Requested game mode, TODO: enum
}

///|
impl @mc.Packet for ChangeGameModeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChangeGameModeC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.game_mode)
}

///|
impl @mc.Packet for ChangeGameModeC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { game_mode: @types.read_varint(buf) }
}

