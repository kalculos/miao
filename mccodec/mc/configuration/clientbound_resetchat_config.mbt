///|
/// Reset Chat packet (0x06)
/// Resets chat on the client
struct ResetChatS2C {}

///|
impl @mc.Packet for ResetChatS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ResetChatS2C with serialize(self, buf : &@buffer.Buffer) {
  // No fields to serialize
}

///|
impl @mc.Packet for ResetChatS2C with deserialize(buf : &@buffer.Buffer) {
  ResetChatS2C::{  }
}

