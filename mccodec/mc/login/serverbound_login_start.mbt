///|
/// Login Start packet (0x00)
/// Initial packet sent by client to start login process
struct LoginStartC2S {
  name : String // Player's username (16 chars max)
  player_uuid : @uuid.UUID // UUID of the player logging in (unused by vanilla)
}

///|
impl @mc.Packet for LoginStartC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for LoginStartC2S with serialize(self, buf : &@bytebuf.ByteBuf) {
  @types.write_string(buf, self.name)
  @types.write_uuid(buf, self.player_uuid)
}

///|
impl @mc.Packet for LoginStartC2S with deserialize(buf : &@bytebuf.ByteBuf) {
  let name = @types.read_string(buf)
  let player_uuid = @types.read_uuid(buf)
  { name, player_uuid }
}
