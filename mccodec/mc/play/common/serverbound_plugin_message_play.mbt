///|
/// Serverbound Plugin Message (play) packet (0x15)
/// Plugin message to server
pub(all) struct ServerboundPluginMessagePlayC2S {
  channel : @types.Identifier // Plugin channel
  data : FixedArray[Byte] // Plugin data
}

///|
pub impl @mc.Packet for ServerboundPluginMessagePlayC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ServerboundPluginMessagePlayC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_identifier(buf, self.channel)
  buf.write(self.data, 0, self.data.length()) |> ignore
}

///|
pub impl @mc.Packet for ServerboundPluginMessagePlayC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let channel = @types.read_identifier(buf)
  let data = buf.read_bytes(buf.readable_bytes()).to_fixedarray()
  { channel, data }
}
