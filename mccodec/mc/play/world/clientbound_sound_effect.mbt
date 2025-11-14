///|
/// Sound Effect packet (0x6E)
/// Plays positioned sound
pub(all) struct SoundEffectS2C {
  sound_id : Int // Sound ID
  sound_category : Int // Sound category
  x : Int // X position (*8)
  y : Int // Y position (*8)
  z : Int // Z position (*8)
  volume : Float // Sound volume
  pitch : Float // Sound pitch
  seed : Int64 // Random seed
}
///|
pub impl @mc.Packet for SoundEffectS2C with clientbound(_) {
  true
}