///|
/// Player Loaded packet (0x2B)
/// Indicates player has loaded
struct PlayerLoadedC2S {}

///|
impl @mc.Packet for PlayerLoadedC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerLoadedC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for PlayerLoadedC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  PlayerLoadedC2S::{  }
}

