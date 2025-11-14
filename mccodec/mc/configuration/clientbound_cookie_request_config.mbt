///|
/// Cookie Request (configuration) packet (0x00)
/// Requests a cookie that was previously stored
pub(all) struct CookieRequestConfigS2C {
  key : @types.Identifier // Identifier of the cookie
}

///|
pub impl @mc.Packet for CookieRequestConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for CookieRequestConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_identifier(buf, self.key)
}

///|
pub impl @mc.Packet for CookieRequestConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  { key: @types.read_identifier(buf) }
}
