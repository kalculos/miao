///|
/// Cookie Request (configuration) packet (0x00)
/// Requests a cookie that was previously stored
struct CookieRequestConfigS2C {
  key : String // Identifier of the cookie, TODO: Identifier type
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
  @types.write_string(buf, self.key)
}

///|
impl @mc.Packet for CookieRequestConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { key: @types.read_string(buf) }
}
