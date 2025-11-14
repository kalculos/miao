///|
/// Reset Chat packet (0x06)
/// Resets chat on the client
pub(all) struct ResetChatS2C {}

///|
pub impl @mc.Packet for ResetChatS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ResetChatS2C with serialize(_, _ : &@buffer.Buffer) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for ResetChatS2C with deserialize(_ : &@buffer.Buffer) {
  ResetChatS2C::{  }
}

