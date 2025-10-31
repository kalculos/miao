///|
/// Cookie Response (configuration) packet (0x01)
/// Response to cookie request from server
struct CookieResponseConfigC2S {
  key : @types.Identifier // Cookie identifier
  payload : FixedArray[Byte]? // Cookie data (up to 5 kiB)
}

///|
impl @mc.Packet for CookieResponseConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CookieResponseConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_identifier(buf, self.key)
  @types.write_optional(buf, self.payload, (b, p) => @types.write_prefix_array(
    b,
    p,
    @bytebuf.ByteWriter::write_byte,
  ))
}

///|
impl @mc.Packet for CookieResponseConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let key = @types.read_identifier(buf)
  let payload = @types.read_optional(buf, b => @types.read_prefix_array(b, by => by
    .read_byte()
    .unwrap_or(0)))
  { key, payload }
}
