///|
/// Ping (play) packet (0x36)
/// Server ping packet
struct PingPlayS2C {
  id : Int // Ping ID
}

///|
impl @mc.Packet for PingPlayS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for PingPlayS2C with serialize(self, buf : &@buffer.Buffer) raise {
  buf.write_int(self.id)
}

///|
impl @mc.Packet for PingPlayS2C with deserialize(buf : &@buffer.Buffer) raise {
  let id = buf.read_int()
  { id, }
}
