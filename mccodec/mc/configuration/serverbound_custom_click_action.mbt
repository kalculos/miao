///|
/// Custom Click Action (configuration) packet (0x08)
/// Sent when the client clicks a Text Component with the minecraft:custom click action.
/// This is meant as an alternative to running a command, but it will not have any effect on vanilla servers.
struct CustomClickActionC2S {
  id : String // The identifier for the click action, TODO: Identifier type
  payload : @nbt.NBTTag // The data to send with the click action. May be a TAG_END (0).
}

///|
impl @mc.Packet for CustomClickActionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CustomClickActionC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.id)
  // TODO: Implement NBT writing
  panic()
}

///|
impl @mc.Packet for CustomClickActionC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let id = @types.read_string(buf)
  // TODO: Implement NBT reading
  panic()
}
