///|
/// Clientbound Keep Alive (play) packet (0x26)
/// Keep connection alive
struct ClientboundKeepAlivePlayS2C {
  keep_alive_id : Int64 // Keep alive ID
}

///|
impl @mc.Packet for ClientboundKeepAlivePlayS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ClientboundKeepAlivePlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  buf.write_int64(self.keep_alive_id)
}

///|
impl @mc.Packet for ClientboundKeepAlivePlayS2C with deserialize(
  buf : &@buffer.Buffer,
) raise {
  let keep_alive_id = buf.read_int64()
  { keep_alive_id, }
}
