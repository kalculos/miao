///|
/// Status Request packet (0x00)
/// Requests server status information, has no fields
struct StatusRequestC2S {}

///|
impl @mc.Packet for StatusRequestC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for StatusRequestC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for StatusRequestC2S with deserialize(buf : &@buffer.Buffer) {
  StatusRequestC2S::{  }
}
