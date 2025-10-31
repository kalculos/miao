///|
/// Finish Configuration packet (0x03)
/// Notifies client that configuration process has finished
struct FinishConfigurationS2C {}

///|
impl @mc.Packet for FinishConfigurationS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for FinishConfigurationS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for FinishConfigurationS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  FinishConfigurationS2C::{  }
}
