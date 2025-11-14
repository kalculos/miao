///|
/// Login Acknowledged packet (0x03)
/// Acknowledges Login Success, switches to configuration state
pub(all) struct LoginAcknowledgedC2S {}

///|
pub impl @mc.Packet for LoginAcknowledgedC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for LoginAcknowledgedC2S with serialize(
  _,
  _ : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for LoginAcknowledgedC2S with deserialize(
  _ : &@buffer.Buffer,
) {
  LoginAcknowledgedC2S::{  } // No fields to deserialize
}
