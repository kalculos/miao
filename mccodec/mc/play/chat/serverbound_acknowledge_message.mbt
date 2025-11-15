///|
/// Acknowledge Message packet (0x05)
/// Acknowledges chat message receipt
pub(all) struct AcknowledgeMessageC2S {
  message_count : Int // Number of messages acknowledged
}

///|
pub impl @mc.Packet for AcknowledgeMessageC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for AcknowledgeMessageC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.message_count)
}

///|
pub impl @mc.Packet for AcknowledgeMessageC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { message_count: @types.read_varint(buf) }
}
