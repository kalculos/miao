///|
/// Click Container Button packet (0x10)
/// Clicks interface button
struct ClickContainerButtonC2S {
  window_id : Int // Window ID
  button_id : Int // Button ID
}

///|
impl @mc.Packet for ClickContainerButtonC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ClickContainerButtonC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.window_id)
  @types.write_varint(buf, self.button_id)
}

///|
impl @mc.Packet for ClickContainerButtonC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let window_id = @types.read_varint(buf)
  let button_id = @types.read_varint(buf)
  { window_id, button_id }
}

