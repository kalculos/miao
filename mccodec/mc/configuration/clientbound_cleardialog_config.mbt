///|
/// Clear Dialog (configuration) packet (0x11)
/// Removes current dialog screen
pub(all) struct ClearDialogConfigS2C {}

///|
pub impl @mc.Packet for ClearDialogConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ClearDialogConfigS2C with serialize(
  _,
  _ : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for ClearDialogConfigS2C with deserialize(
  _ : &@buffer.Buffer,
) {
  ClearDialogConfigS2C::{  }
}

