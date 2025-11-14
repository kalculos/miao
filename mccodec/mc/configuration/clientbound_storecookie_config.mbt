///|
/// Store Cookie (configuration) packet (0x0A)
/// Stores arbitrary data on client
pub(all) struct StoreCookieConfigS2C {
  key : @types.Identifier // Cookie identifier
  payload : FixedArray[Byte] // Cookie data (up to 5 kiB)
}

///|
pub impl @mc.Packet for StoreCookieConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for StoreCookieConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_identifier(buf, self.key)
  @types.write_prefix_array(buf, self.payload, @buffer.ByteSlice::write_byte)
}

///|
pub impl @mc.Packet for StoreCookieConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let key = @types.read_identifier(buf)
  let payload = @types.read_prefix_array(buf, b => b.read_byte())
  { key, payload }
}

