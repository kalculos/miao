///|
/// Cookie Request (login) packet (0x05)
/// Requests a previously stored cookie
struct CookieRequestLoginS2C {
  key : @types.Identifier // Identifier of the cookie
}

///|
impl @mc.Packet for CookieRequestLoginS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for CookieRequestLoginS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_identifier(buf, self.key)
}

///|
impl @mc.Packet for CookieRequestLoginS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let key = @types.read_identifier(buf)
  { key, }
}
