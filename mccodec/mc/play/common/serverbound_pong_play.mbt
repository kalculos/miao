///|
/// Pong (play) packet (0x2C)
/// Pong response to server ping
struct PongPlayC2S {
  id : Int // Ping ID from server
}

///|
impl @mc.Packet for PongPlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PongPlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.id)
}

///|
impl @mc.Packet for PongPlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { id: @types.read_varint(buf) }
}

