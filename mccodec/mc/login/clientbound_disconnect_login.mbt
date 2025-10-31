///|
/// Disconnect (login) packet (0x00)
/// Sent when the server disconnects a client during login
struct DisconnectLoginS2C {
  reason : String // JSON Text Component, TODO: Component type
}

///|
impl @mc.Packet for DisconnectLoginS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for DisconnectLoginS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.reason)
}

///|
impl @mc.Packet for DisconnectLoginS2C with deserialize(buf : &@buffer.Buffer) {
  let reason_str = @types.read_string(buf)
  { reason: reason_str }
}
