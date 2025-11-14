///|
/// Login Start packet (0x00)
/// Initial packet sent by client to start login process
pub(all) struct LoginStartC2S {
  name : String // Player's username (16 chars max)
  player_uuid : @uuid.UUID // UUID of the player logging in (unused by vanilla)
}

///|
pub impl @mc.Packet for LoginStartC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for LoginStartC2S with serialize(self, buf : &@buffer.Buffer) {
  @types.write_string(buf, self.name)
  @types.write_uuid(buf, self.player_uuid)
}

///|
pub impl @mc.Packet for LoginStartC2S with deserialize(buf : &@buffer.Buffer) {
  let name = @types.read_string(buf)
  let player_uuid = @types.read_uuid(buf)
  { name, player_uuid }
}
