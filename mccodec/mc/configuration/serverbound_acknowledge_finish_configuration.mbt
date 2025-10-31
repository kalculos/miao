///|
/// Acknowledge Finish Configuration packet (0x03)
/// Acknowledges server's Finish Configuration packet
struct AcknowledgeFinishConfigurationC2S {}

///|
impl @mc.Packet for AcknowledgeFinishConfigurationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for AcknowledgeFinishConfigurationC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for AcknowledgeFinishConfigurationC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  AcknowledgeFinishConfigurationC2S::{  }
}

