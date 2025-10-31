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
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for AcknowledgeConfigurationC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  AcknowledgeConfigurationC2S::{  }
}

