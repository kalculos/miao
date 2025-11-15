///|
/// Entity Effect packet (0x7D)
/// Applies entity effect
pub(all) struct EntityEffectS2C {
  entity_id : Int // Entity ID
  effect_id : Int // Effect ID
  amplifier : Int // Effect amplifier
  duration : Int // Effect duration
  flags : Byte // Effect flags
  factor_data : String? // Factor calculation data
}

///|
pub impl @mc.Packet for EntityEffectS2C with clientbound(_) {
  true
}
