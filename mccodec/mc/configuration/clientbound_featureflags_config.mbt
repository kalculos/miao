///|
/// Feature Flags packet (0x0C)
/// Enables and disables features on client
pub(all) struct FeatureFlagsS2C {
  feature_flags : FixedArray[@types.Identifier] // Array of feature flag identifiers
}

///|
pub impl @mc.Packet for FeatureFlagsS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for FeatureFlagsS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_prefix_array(buf, self.feature_flags, @types.write_identifier)
}

///|
pub impl @mc.Packet for FeatureFlagsS2C with deserialize(buf : &@buffer.Buffer) {
  let feature_flags = @types.read_prefix_array(buf, @types.read_identifier)
  { feature_flags, }
}

