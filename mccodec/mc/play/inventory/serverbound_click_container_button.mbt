///|
/// Click Container Button packet (0x10)
/// Clicks interface button
pub(all) struct ClickContainerButtonC2S {
  window_id : Int // Window ID
  button_id : Int // Button ID
}

///|
pub impl @mc.Packet for ClickContainerButtonC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ClickContainerButtonC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.window_id)
  @types.write_varint(buf, self.button_id)
}

///|
pub impl @mc.Packet for ClickContainerButtonC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let window_id = @types.read_varint(buf)
  let button_id = @types.read_varint(buf)
  { window_id, button_id }
}
