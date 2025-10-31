///|
/// Login Plugin Response packet (0x02)
/// Response to login plugin request
struct LoginPluginResponseC2S {
  message_id : Int // Should match ID from server
  data : FixedArray[Byte]? // Plugin data if client understood the request
}

///|
impl @mc.Packet for LoginPluginResponseC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for LoginPluginResponseC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.message_id)
  @types.write_optional(buf, self.data, (b, d) => b.write(d, 0, d.length()) |> ignore)
}

///|
impl @mc.Packet for LoginPluginResponseC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let message_id = @types.read_varint(buf)
  let data = @types.read_optional(buf, b => {
    let remaining = b.readable_bytes()
    let bytes = b.read_bytes(remaining).to_fixedarray()
    bytes
  })
  { message_id, data }
}
