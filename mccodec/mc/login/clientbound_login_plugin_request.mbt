///|
/// Login Plugin Request packet (0x04)
/// Custom handshaking flow for plugin messages
struct LoginPluginRequestS2C {
  message_id : Int // Unique to the connection
  channel : @types.Identifier // Plugin channel identifier
  data : Array[Byte] // Plugin data
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
  buf.write_bytes(Bytes::from_array(self.data))
}

///|
impl @mc.Packet for LoginPluginRequestS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let message_id = @types.read_varint(buf)
  let channel = @types.read_identifier(buf)
  let data = buf.read_bytes(buf.remaining()).unwrap().to_array()
  { message_id, channel, data }
}
