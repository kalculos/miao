///|
/// Remove Entity Effect packet (0x47)
/// Removes effect from entity
pub(all) struct RemoveEntityEffectS2C {
  entity_id : Int // Entity ID
  effect_id : Int // Effect ID to remove
}

///|
pub impl @mc.Packet for RemoveEntityEffectS2C with clientbound(_) {
  true
}
