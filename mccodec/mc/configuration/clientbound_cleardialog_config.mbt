///|
/// Clear Dialog (configuration) packet (0x11)
/// Removes current dialog screen
struct ClearDialogConfigS2C {}

///|
impl @mc.Packet for ClearDialogConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ClearDialogConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for ClearDialogConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  ClearDialogConfigS2C::{  }
}

