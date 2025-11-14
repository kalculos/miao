///|
/// Disconnect (play) packet (0x1C)
/// Disconnects player during play
pub(all) struct DisconnectPlayS2C {
  reason : String // JSON disconnect reason, TODO: Text Component
}

///|
pub impl @mc.Packet for DisconnectPlayS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for DisconnectPlayS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  @types.write_string(buf, self.reason)
}

///|
pub impl @mc.Packet for DisconnectPlayS2C with deserialize(buf : &@buffer.Buffer) raise {
  let reason = @types.read_string(buf)
  { reason, }
}
