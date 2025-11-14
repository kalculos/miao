///|
/// Serverbound Keep Alive (configuration) packet (0x04)
/// Client response to server's keep alive
pub(all) struct ServerboundKeepAliveConfigC2S {
  keep_alive_id : Int64 // Must match server's keep alive ID
}

///|
pub impl @mc.Packet for ServerboundKeepAliveConfigC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ServerboundKeepAliveConfigC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int64(self.keep_alive_id)
}

///|
pub impl @mc.Packet for ServerboundKeepAliveConfigC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { keep_alive_id: buf.read_int64() }
}

