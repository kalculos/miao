///|
/// Serverbound Keep Alive (play) packet (0x1B)
/// Keep alive response
pub(all) struct ServerboundKeepAlivePlayC2S {
  keep_alive_id : Int64 // Keep alive ID from server
}

///|
pub impl @mc.Packet for ServerboundKeepAlivePlayC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ServerboundKeepAlivePlayC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int64(self.keep_alive_id)
}

///|
pub impl @mc.Packet for ServerboundKeepAlivePlayC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { keep_alive_id: buf.read_int64() }
}

