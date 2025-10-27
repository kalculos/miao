///|
/// Entity Sound Effect packet (0x6D)
/// Plays sound from entity
struct EntitySoundEffectS2C {
  sound_id : Int // Sound ID
  sound_category : Int // Sound category
  entity_id : Int // Entity ID
  volume : Float // Sound volume
  pitch : Float // Sound pitch
  seed : Int64 // Random seed
}
///|
impl @mc.Packet for EntitySoundEffectS2C with clientbound(self) {
  true
}