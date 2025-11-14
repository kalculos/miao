///|
/// Clientbound Keep Alive (play) packet (0x26)
/// Keep connection alive
pub(all) struct ClientboundKeepAlivePlayS2C {
  keep_alive_id : Int64 // Keep alive ID
}

///|
pub impl @mc.Packet for ClientboundKeepAlivePlayS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ClientboundKeepAlivePlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  buf.write_int64(self.keep_alive_id)
}

///|
pub impl @mc.Packet for ClientboundKeepAlivePlayS2C with deserialize(
  buf : &@buffer.Buffer,
) raise {
  let keep_alive_id = buf.read_int64()
  { keep_alive_id, }
}
