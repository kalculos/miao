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
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for PlayerLoadedC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  PlayerLoadedC2S::{  }
}

