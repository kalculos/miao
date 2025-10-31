///|
/// Remove Entity Effect packet (0x47)
/// Removes effect from entity
struct RemoveEntityEffectS2C {
  entity_id : Int // Entity ID
  effect_id : Int // Effect ID to remove
}
///|
impl @mc.Packet for RemoveEntityEffectS2C with clientbound(self) {
  true
}