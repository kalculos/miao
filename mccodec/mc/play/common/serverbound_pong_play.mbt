///|
/// Pong (play) packet (0x2C)
/// Pong response to server ping
pub(all) struct PongPlayC2S {
  id : Int // Ping ID from server
}

///|
pub impl @mc.Packet for PongPlayC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PongPlayC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.id)
}

///|
pub impl @mc.Packet for PongPlayC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { id: @types.read_varint(buf) }
}

