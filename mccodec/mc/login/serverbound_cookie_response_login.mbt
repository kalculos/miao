///|
/// Cookie Response (login) packet (0x04)
/// Response to cookie request during login
pub(all) struct CookieResponseLoginC2S {
  key : @types.Identifier // Identifier of the cookie
  payload : FixedArray[Byte]? // Cookie data (up to 5 kiB)
}

///|
pub impl @mc.Packet for CookieResponseLoginC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for CookieResponseLoginC2S with serialize(
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
pub impl @mc.Packet for CookieResponseLoginC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let key = @types.read_identifier(buf)
  let payload = @types.read_optional(buf, b => @types.read_prefix_array(b, by => by
    .read_byte()))
  { key, payload }
}
