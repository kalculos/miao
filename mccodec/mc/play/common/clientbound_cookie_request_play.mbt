///|
/// Cookie Request (play) packet (0x15)
/// Requests a stored cookie
pub(all) struct CookieRequestPlayS2C {
  key : @types.Identifier // Cookie identifier
}

///|
pub impl @mc.Packet for CookieRequestPlayS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for CookieRequestPlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  @types.write_identifier(buf, self.key)
}

///|
pub impl @mc.Packet for CookieRequestPlayS2C with deserialize(
  buf : &@buffer.Buffer,
) raise {
  let key = @types.read_identifier(buf)
  { key, }
}
