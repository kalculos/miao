///|
/// Set Compression packet (0x03)
/// Enables compression for all following packets (optional)
struct SetCompressionS2C {
  threshold : Int // Maximum packet size before compression
}

///|
impl @mc.Packet for SetCompressionS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for SetCompressionS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.threshold)
}

///|
impl @mc.Packet for SetCompressionS2C with deserialize(buf : &@buffer.Buffer) {
  let threshold = @types.read_varint(buf)
  { threshold, }
}
