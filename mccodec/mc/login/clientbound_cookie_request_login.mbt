///|
/// Cookie Request (login) packet (0x05)
/// Requests a previously stored cookie
struct CookieRequestLoginS2C {
  key : String // Identifier of the cookie, TODO: Identifier type
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
  @types.write_string(buf, self.key)
}

///|
impl @mc.Packet for CookieRequestLoginS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let key = @types.read_string(buf)
  { key, }
}
