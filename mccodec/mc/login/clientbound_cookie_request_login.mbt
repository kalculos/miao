///|
/// Cookie Request (login) packet (0x05)
/// Requests a previously stored cookie
pub(all) struct CookieRequestLoginS2C {
  key : @types.Identifier // Identifier of the cookie
}

///|
pub impl @mc.Packet for CookieRequestLoginS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for CookieRequestLoginS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_identifier(buf, self.key)
}

///|
pub impl @mc.Packet for CookieRequestLoginS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let key = @types.read_identifier(buf)
  { key, }
}
