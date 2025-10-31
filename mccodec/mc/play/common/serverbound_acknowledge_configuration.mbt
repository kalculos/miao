///|
/// Acknowledge Configuration packet (0x0F)
/// Acknowledges configuration completion
struct AcknowledgeConfigurationC2S {}

///|
impl @mc.Packet for AcknowledgeConfigurationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for AcknowledgeConfigurationC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for AcknowledgeConfigurationC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  AcknowledgeConfigurationC2S::{  }
}

