///|
/// Disconnect (configuration) packet (0x02)
/// Sent when disconnecting during configuration
pub(all) struct DisconnectConfigS2C {
  reason : String // Text Component - reason for disconnection, TODO: Component type
}

///|
pub impl @mc.Packet for DisconnectConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for DisconnectConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.reason)
}

///|
pub impl @mc.Packet for DisconnectConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  { reason: @types.read_string(buf) }
}
