///|
/// Login Plugin Request packet (0x04)
/// Custom handshaking flow for plugin messages
struct LoginPluginRequestS2C {
  message_id : Int // Unique to the connection
  channel : String // Plugin channel identifier, TODO: Identifier type
  data : Array[Byte] // Plugin data
}

///|
impl @mc.Packet for LoginPluginRequestS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for LoginPluginRequestS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.message_id)
  @types.write_string(buf, self.channel)
  buf.write_bytes(Bytes::from_array(self.data))
}

///|
impl @mc.Packet for LoginPluginRequestS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let message_id = @types.read_varint(buf)
  let channel = @types.read_string(buf)
  let data = buf.read_bytes(buf.remaining()).unwrap().to_array()
  { message_id, channel, data }
}
