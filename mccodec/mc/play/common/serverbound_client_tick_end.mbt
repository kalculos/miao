///|
/// Client Tick End packet (0x0C)
/// Marks end of client tick
struct ClientTickEndC2S {}

///|
impl @mc.Packet for ClientTickEndC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClientTickEndC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for ClientTickEndC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  ClientTickEndC2S::{  }
}

