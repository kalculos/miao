///|
/// Disconnect (login) packet (0x00)
/// Sent when the server disconnects a client during login
pub(all) struct DisconnectLoginS2C {
  reason : String // JSON Text Component, TODO: Component type
}

///|
pub impl @mc.Packet for DisconnectLoginS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for DisconnectLoginS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.reason)
}

///|
pub impl @mc.Packet for DisconnectLoginS2C with deserialize(buf : &@buffer.Buffer) {
  let reason_str = @types.read_string(buf)
  { reason: reason_str }
}
