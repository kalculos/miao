///|
/// Acknowledge Block Change packet (0x04)
/// Acknowledges block change prediction
pub(all) struct AcknowledgeBlockChangeS2C {
  sequence_id : Int // Sequence ID to acknowledge
}
///|
pub impl @mc.Packet for AcknowledgeBlockChangeS2C with clientbound(_) {
  true
}