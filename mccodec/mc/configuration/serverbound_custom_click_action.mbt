///|
/// Custom Click Action (configuration) packet (0x08)
/// Sent when the client clicks a Text Component with the minecraft:custom click action.
/// This is meant as an alternative to running a command, but it will not have any effect on vanilla servers.
pub(all) struct CustomClickActionC2S {
  id : @types.Identifier // The identifier for the click action
  payload : @nbt.NBTTag // The data to send with the click action. May be a TAG_END (0).
}

///|
pub impl @mc.Packet for CustomClickActionC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for CustomClickActionC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_identifier(buf, self.id)
  // TODO: Implement NBT writing
  panic()
}

///|
pub impl @mc.Packet for CustomClickActionC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let _ = @types.read_identifier(buf)
  // TODO: Implement NBT reading
  panic()
}
