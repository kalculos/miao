///|
/// Cookie Response (play) packet (0x14)
/// Response to cookie request
pub(all) struct CookieResponsePlayC2S {
  key : @types.Identifier // Cookie key
  payload : FixedArray[Byte]? // Cookie data
}

///|
pub impl @mc.Packet for CookieResponsePlayC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for CookieResponsePlayC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_identifier(buf, self.key)
  @types.write_optional(buf, self.payload, (b, p) => @types.write_prefix_array(
    b,
    p,
    @buffer.ByteSlice::write_byte,
  ))
}

///|
pub impl @mc.Packet for CookieResponsePlayC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let key = @types.read_identifier(buf)
  let payload = @types.read_optional(buf, b => {
    @types.read_prefix_array(b, by => by.read_byte())
  })
  { key, payload }
}

