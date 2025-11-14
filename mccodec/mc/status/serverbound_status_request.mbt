///|
/// Status Request packet (0x00)
/// Requests server status information, has no fields
pub(all) struct StatusRequestC2S {}

///|
pub impl @mc.Packet for StatusRequestC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for StatusRequestC2S with serialize(
  _,
  _ : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for StatusRequestC2S with deserialize(_ : &@buffer.Buffer) {
  StatusRequestC2S::{  }
}
