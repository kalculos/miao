///|
/// Cookie Request (configuration) packet (0x00)
/// Requests a cookie that was previously stored
struct CookieRequestConfigS2C {
  key : @types.Identifier // Identifier of the cookie
}

///|
impl @mc.Packet for CookieRequestConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for CookieRequestConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_identifier(buf, self.key)
}

///|
impl @mc.Packet for CookieRequestConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { key: @types.read_identifier(buf) }
}
