///|
/// Set Compression packet (0x03)
/// Enables compression for all following packets (optional)
pub(all) struct SetCompressionS2C {
  threshold : Int // Maximum packet size before compression
}

///|
pub impl @mc.Packet for SetCompressionS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for SetCompressionS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.threshold)
}

///|
pub impl @mc.Packet for SetCompressionS2C with deserialize(buf : &@buffer.Buffer) {
  let threshold = @types.read_varint(buf)
  { threshold, }
}
