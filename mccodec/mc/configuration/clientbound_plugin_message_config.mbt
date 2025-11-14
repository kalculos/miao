///|
/// Clientbound Plugin Message (configuration) packet (0x01)
/// Mods and plugins can use this to send data
pub(all) struct ClientboundPluginMessageConfigS2C {
  channel : String // Plugin channel identifier
  data : FixedArray[Byte] // Plugin data (max 1048576 bytes)
}

///|
pub impl @mc.Packet for ClientboundPluginMessageConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ClientboundPluginMessageConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.channel)
  buf.write(self.data, 0, self.data.length()) |> ignore
}

///|
pub impl @mc.Packet for ClientboundPluginMessageConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let channel = @types.read_string(buf)
  let data = buf.read_bytes(buf.readable_bytes()).to_fixedarray()
  { channel, data }
}
