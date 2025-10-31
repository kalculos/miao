///|
/// Login Plugin Request packet (0x04)
/// Custom handshaking flow for plugin messages
struct LoginPluginRequestS2C {
  message_id : Int // Unique to the connection
  channel : @types.Identifier // Plugin channel identifier
  data : FixedArray[Byte] // Plugin data
}

///|
impl @mc.Packet for LoginPluginRequestS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for LoginPluginRequestS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.message_id)
  @types.write_identifier(buf, self.channel)
  buf.write(self.data, 0, self.data.length()) |> ignore
}

///|
impl @mc.Packet for LoginPluginRequestS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let message_id = @types.read_varint(buf)
  let channel = @types.read_identifier(buf)
  let data = buf.read_bytes(buf.readable_bytes()).to_fixedarray()
  { message_id, channel, data }
}
