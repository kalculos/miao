///|
/// Clientbound Plugin Message (configuration) packet (0x01)
/// Mods and plugins can use this to send data
struct ClientboundPluginMessageConfigS2C {
  channel : String // Plugin channel identifier
  data : FixedArray[Byte] // Plugin data (max 1048576 bytes)
}

///|
impl @mc.Packet for ClientboundPluginMessageConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ClientboundPluginMessageConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.channel)
  buf.write(self.data, 0, self.data.length()) |> ignore
}

///|
impl @mc.Packet for ClientboundPluginMessageConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let channel = @types.read_string(buf)
  let data = buf.read_bytes(buf.readable_bytes()).to_fixedarray()
  { channel, data }
}
