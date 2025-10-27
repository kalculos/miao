///|
/// Login Plugin Response packet (0x02)
/// Response to login plugin request
struct LoginPluginResponseC2S {
  message_id : Int // Should match ID from server
  data : Array[Byte]? // Plugin data if client understood the request
}

///|
impl @mc.Packet for LoginPluginResponseC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for LoginPluginResponseC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.message_id)
  @types.write_optional(buf, self.data, (b, d) => b.write_bytes(
    Bytes::from_array(d),
  ))
}

///|
impl @mc.Packet for LoginPluginResponseC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let message_id = @types.read_varint(buf)
  let data = @types.read_optional(buf, b => {
    let remaining = b.remaining()
    let bytes = b.read_bytes(remaining).unwrap().to_array()
    bytes
  })
  { message_id, data }
}
