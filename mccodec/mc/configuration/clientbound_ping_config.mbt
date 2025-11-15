///|
/// Ping (configuration) packet (0x05)
/// Server ping packet (not used by vanilla server)
pub(all) struct PingConfigS2C {
  id : Int // Ping ID
}

///|
pub impl @mc.Packet for PingConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for PingConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int(self.id)
}

///|
pub impl @mc.Packet for PingConfigS2C with deserialize(buf : &@buffer.Buffer) {
  { id: buf.read_int() }
}
