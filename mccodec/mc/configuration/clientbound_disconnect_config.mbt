///|
/// Disconnect (configuration) packet (0x02)
/// Sent when disconnecting during configuration
struct DisconnectConfigS2C {
  reason : String // Text Component - reason for disconnection, TODO: Component type
}

///|
impl @mc.Packet for DisconnectConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for DisconnectConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.reason)
}

///|
impl @mc.Packet for DisconnectConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { reason: @types.read_string(buf) }
}
