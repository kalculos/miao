///|
/// Set Beacon Effect packet (0x33)
/// Sets beacon effects
pub(all) struct SetBeaconEffectC2S {
  primary_effect : Int? // Primary effect ID  
  secondary_effect : Int? // Secondary effect ID
}

///|
pub impl @mc.Packet for SetBeaconEffectC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for SetBeaconEffectC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_optional(buf, self.primary_effect, @types.write_varint)
  @types.write_optional(buf, self.secondary_effect, @types.write_varint)
}

///|
pub impl @mc.Packet for SetBeaconEffectC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let primary_effect = @types.read_optional(buf, @types.read_varint)
  let secondary_effect = @types.read_optional(buf, @types.read_varint)
  { primary_effect, secondary_effect }
}
