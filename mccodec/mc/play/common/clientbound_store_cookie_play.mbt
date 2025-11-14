///|
/// Store Cookie (play) packet (0x71)
/// Stores cookie on client
pub(all) struct StoreCookiePlayS2C {
  key : @types.Identifier // Cookie key
  payload : FixedArray[Byte] // Cookie payload
}

///|
pub impl @mc.Packet for StoreCookiePlayS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for StoreCookiePlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  @types.write_identifier(buf, self.key)
  @types.write_prefix_array(buf, self.payload, @buffer.ByteSlice::write_byte)
}

///|
pub impl @mc.Packet for StoreCookiePlayS2C with deserialize(buf : &@buffer.Buffer) raise {
  let key = @types.read_identifier(buf)
  let payload = @types.read_prefix_array(buf, @buffer.ByteSlice::read_byte)
  { key, payload }
}
