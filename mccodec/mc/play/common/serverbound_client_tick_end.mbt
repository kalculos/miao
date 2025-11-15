///|
/// Client Tick End packet (0x0C)
/// Marks end of client tick
pub(all) struct ClientTickEndC2S {}

///|
pub impl @mc.Packet for ClientTickEndC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ClientTickEndC2S with serialize(_, _ : &@buffer.Buffer) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for ClientTickEndC2S with deserialize(_ : &@buffer.Buffer) {
  ClientTickEndC2S::{  }
}
