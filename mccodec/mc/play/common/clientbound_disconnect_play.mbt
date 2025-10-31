///|
/// Disconnect (play) packet (0x1C)
/// Disconnects player during play
struct DisconnectPlayS2C {
  reason : String // JSON disconnect reason, TODO: Text Component
}

///|
impl @mc.Packet for DisconnectPlayS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for DisconnectPlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  @types.write_string(buf, self.reason)
}

///|
impl @mc.Packet for DisconnectPlayS2C with deserialize(buf : &@buffer.Buffer) raise {
  let reason = @types.read_string(buf)
  { reason, }
}
