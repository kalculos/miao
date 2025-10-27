///|
/// Clientbound Plugin Message (configuration) packet (0x01)
/// Mods and plugins can use this to send data
struct ClientboundPluginMessageConfigS2C {
  channel : String // Plugin channel identifier
  data : Array[Byte] // Plugin data (max 1048576 bytes)
}

///|
impl @mc.Packet for ClientboundPluginMessageConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ClientboundPluginMessageConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.channel)
  buf.write_bytes(Bytes::from_array(self.data))
}

///|
impl @mc.Packet for ClientboundPluginMessageConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let channel = @types.read_string(buf)
  let data = buf.read_bytes(buf.remaining()).unwrap().to_array()
  { channel, data }
}
