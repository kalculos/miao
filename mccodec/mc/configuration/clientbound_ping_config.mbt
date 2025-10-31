///|
/// Ping (configuration) packet (0x05)
/// Server ping packet (not used by vanilla server)
struct PingConfigS2C {
  id : Int // Ping ID
}

///|
impl @mc.Packet for PingConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for PingConfigS2C with serialize(self, buf : &@bytebuf.ByteBuf) {
  buf.write_int(self.id)
}

///|
impl @mc.Packet for PingConfigS2C with deserialize(buf : &@bytebuf.ByteBuf) {
  { id: buf.read_int().unwrap() }
}

