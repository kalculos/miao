///|
/// Finish Configuration packet (0x03)
/// Notifies client that configuration process has finished
pub(all) struct FinishConfigurationS2C {}

///|
pub impl @mc.Packet for FinishConfigurationS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for FinishConfigurationS2C with serialize(
  _,
  _ : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for FinishConfigurationS2C with deserialize(
  _ : &@buffer.Buffer,
) {
  FinishConfigurationS2C::{  }
}
