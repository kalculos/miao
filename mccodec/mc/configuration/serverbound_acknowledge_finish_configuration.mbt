///|
/// Acknowledge Finish Configuration packet (0x03)
/// Acknowledges server's Finish Configuration packet
pub(all) struct AcknowledgeFinishConfigurationC2S {}

///|
pub impl @mc.Packet for AcknowledgeFinishConfigurationC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for AcknowledgeFinishConfigurationC2S with serialize(
  _,
  _ : &@buffer.Buffer,
) {
  // No fields to serialize
}

///|
pub impl @mc.Packet for AcknowledgeFinishConfigurationC2S with deserialize(
  _ : &@buffer.Buffer,
) {
  AcknowledgeFinishConfigurationC2S::{  }
}
