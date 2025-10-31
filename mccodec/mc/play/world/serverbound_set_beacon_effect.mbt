///|
/// Set Beacon Effect packet (0x33)
/// Sets beacon effects
struct SetBeaconEffectC2S {
  primary_effect : Int? // Primary effect ID  
  secondary_effect : Int? // Secondary effect ID
}

///|
impl @mc.Packet for SetBeaconEffectC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetBeaconEffectC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_optional(buf, self.primary_effect, @types.write_varint)
  @types.write_optional(buf, self.secondary_effect, @types.write_varint)
}

///|
impl @mc.Packet for SetBeaconEffectC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let primary_effect = @types.read_optional(buf, @types.read_varint)
  let secondary_effect = @types.read_optional(buf, @types.read_varint)
  { primary_effect, secondary_effect }
}

