///|
/// Cookie Request (play) packet (0x15)
/// Requests a stored cookie
struct CookieRequestPlayS2C {
  key : @types.Identifier // Cookie identifier
}

///|
impl @mc.Packet for CookieRequestPlayS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for CookieRequestPlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  @types.write_identifier(buf, self.key)
}

///|
impl @mc.Packet for CookieRequestPlayS2C with deserialize(
  buf : &@buffer.Buffer,
) raise {
  let key = @types.read_identifier(buf)
  { key, }
}
