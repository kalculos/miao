///|
/// Clientbound Plugin Message (play) packet (0x18)
/// Plugin message from server
struct ClientboundPluginMessagePlayS2C {
  channel : @types.Identifier // Plugin channel
  data : &@buffer.Buffer // Plugin data
}

///|
impl @mc.Packet for ClientboundPluginMessagePlayS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ClientboundPluginMessagePlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  @types.write_identifier(buf, self.channel)
  self.data.transfer_to(buf)
}

///|
impl @mc.Packet for ClientboundPluginMessagePlayS2C with deserialize(
  buf : &@buffer.Buffer,
) raise {
  let channel = @types.read_identifier(buf)
  let data = buf.duplicate()
  { channel, data }
}
