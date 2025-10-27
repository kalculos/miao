///|
/// Feature Flags packet (0x0C)
/// Enables and disables features on client
struct FeatureFlagsS2C {
  feature_flags : FixedArray[String] // Array of feature flag identifiers, TODO: Identifier type
}

///|
impl @mc.Packet for FeatureFlagsS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for FeatureFlagsS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_prefix_array(buf, self.feature_flags, @types.write_string)
}

///|
impl @mc.Packet for FeatureFlagsS2C with deserialize(buf : &@bytebuf.ByteBuf) {
  let feature_flags = @types.read_prefix_array(buf, @types.read_string)
  { feature_flags, }
}

