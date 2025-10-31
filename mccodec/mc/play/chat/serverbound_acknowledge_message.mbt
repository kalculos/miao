///|
/// Acknowledge Message packet (0x05)
/// Acknowledges chat message receipt
struct AcknowledgeMessageC2S {
  message_count : Int // Number of messages acknowledged
}

///|
impl @mc.Packet for AcknowledgeMessageC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for AcknowledgeMessageC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.message_count)
}

///|
impl @mc.Packet for AcknowledgeMessageC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { message_count: @types.read_varint(buf) }
}

