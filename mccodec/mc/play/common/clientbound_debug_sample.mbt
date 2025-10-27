///|
/// Debug Sample packet (0x1A)
/// Debug performance sample
struct DebugSampleS2C {
  sample : Array[Int64] // Performance sample data
  sample_type : Int // Sample type
}
///|
impl @mc.Packet for DebugSampleS2C with clientbound(self) {
  true
}