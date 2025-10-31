///|
/// Custom Click Action (0x41) - Server-bound packet
/// Sent when the client clicks a Text Component with the minecraft:custom click action.
struct CustomClickActionC2S {
  id : String // The identifier for the click action
  payload : @nbt.NBTTag // The NBT data to send with the click action. May be a TAG_END (0)
}

///|
impl @mc.Packet for CustomClickActionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CustomClickActionC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.id)
  // TODO: Implement NBT serialization when available
  panic()
}

///|
impl @mc.Packet for CustomClickActionC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let id = @types.read_string(buf)
  // TODO: Implement NBT deserialization when available
  panic()
}