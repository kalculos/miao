///|
/// Debug Sample packet (0x1A)
/// Debug performance sample
struct DebugSampleS2C {
  sample : FixedArray[Int64] // Performance sample data
  sample_type : Int // Sample type, enum(o=ticktime)
}

///|
impl @mc.Packet for DebugSampleS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for DebugSampleS2C with serialize(self, buf : &@buffer.Buffer) raise {
  @types.write_prefix_array(buf, self.sample, (buf, data) => buf.write_int64(
    data,
  ))
  @types.write_varint(buf, self.sample_type)
}

///|
impl @mc.Packet for DebugSampleS2C with deserialize(buf : &@buffer.Buffer) raise {
  let sample = @types.read_prefix_array(buf, buf => buf.read_int64())
  let sample_type = @types.read_varint(buf)
  { sample, sample_type }
}
