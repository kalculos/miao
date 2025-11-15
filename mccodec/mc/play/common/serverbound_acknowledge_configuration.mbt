///|
/// Acknowledge Configuration packet (0x0F)
/// Acknowledges configuration completion
pub(all) struct AcknowledgeConfigurationC2S {}

///|
pub impl @mc.Packet for AcknowledgeConfigurationC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for AcknowledgeConfigurationC2S with serialize(
  _,
  _ : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for AcknowledgeConfigurationC2S with deserialize(
  _ : &@buffer.Buffer,
) {
  AcknowledgeConfigurationC2S::{  }
}
