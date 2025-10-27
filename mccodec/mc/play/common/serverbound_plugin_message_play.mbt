///|
/// Serverbound Plugin Message (play) packet (0x15)
/// Plugin message to server
struct ServerboundPluginMessagePlayC2S {
  channel : String // Plugin channel, TODO: Identifier type
  data : Array[Byte] // Plugin data
}

///|
impl @mc.Packet for ServerboundPluginMessagePlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundPluginMessagePlayC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.channel)
  buf.write_bytes(Bytes::from_array(self.data))
}

///|
impl @mc.Packet for ServerboundPluginMessagePlayC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let channel = @types.read_string(buf)
  let data = buf.read_bytes(buf.remaining()).unwrap().to_array()
  { channel, data }
}

