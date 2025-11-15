///|
/// Player Loaded packet (0x2B)
/// Indicates player has loaded
pub(all) struct PlayerLoadedC2S {}

///|
pub impl @mc.Packet for PlayerLoadedC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PlayerLoadedC2S with serialize(_, _ : &@buffer.Buffer) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for PlayerLoadedC2S with deserialize(_ : &@buffer.Buffer) {
  PlayerLoadedC2S::{  }
}
