///|
/// Debug Sample Subscription packet (0x16)
/// Subscribes to debug samples
pub(all) struct DebugSampleSubscriptionC2S {
  sample_type : Int // Sample type to subscribe to enum(0=tick time)
}

///|
pub impl @mc.Packet for DebugSampleSubscriptionC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for DebugSampleSubscriptionC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.sample_type)
}

///|
pub impl @mc.Packet for DebugSampleSubscriptionC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { sample_type: @types.read_varint(buf) }
}
