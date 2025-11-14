///|
/// Ping (play) packet (0x36)
/// Server ping packet
pub(all) struct PingPlayS2C {
  id : Int // Ping ID
}

///|
pub impl @mc.Packet for PingPlayS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for PingPlayS2C with serialize(self, buf : &@buffer.Buffer) raise {
  buf.write_int(self.id)
}

///|
pub impl @mc.Packet for PingPlayS2C with deserialize(buf : &@buffer.Buffer) raise {
  let id = buf.read_int()
  { id, }
}
