///|
/// Serverbound Plugin Message (configuration) packet (0x02)
/// Mods and plugins use this to send data to server
pub(all) struct ServerboundPluginMessageConfigC2S {
  channel : @types.Identifier // Plugin channel identifier
  data : FixedArray[Byte] // Plugin data (max 32767 bytes)
}

///|
pub impl @mc.Packet for ServerboundPluginMessageConfigC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ServerboundPluginMessageConfigC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_identifier(buf, self.channel)
  buf.write(self.data, 0, self.data.length()) |> ignore
}

///|
pub impl @mc.Packet for ServerboundPluginMessageConfigC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let channel = @types.read_identifier(buf)
  let data = buf.read_bytes(buf.readable_bytes()).to_fixedarray()
  { channel, data }
}

