///|
/// Serverbound Plugin Message (configuration) packet (0x02)
/// Mods and plugins use this to send data to server
struct ServerboundPluginMessageConfigC2S {
  channel : @types.Identifier // Plugin channel identifier
  data : Array[Byte] // Plugin data (max 32767 bytes)
}

///|
impl @mc.Packet for ServerboundPluginMessageConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundPluginMessageConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_identifier(buf, self.channel)
  buf.write_bytes(Bytes::from_array(self.data))
}

///|
impl @mc.Packet for ServerboundPluginMessageConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let channel = @types.read_identifier(buf)
  let data = buf.read_bytes(buf.remaining()).unwrap().to_array()
  { channel, data }
}

