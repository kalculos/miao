///|
/// Close Container packet (0x12)
/// Closes inventory window
pub(all) struct CloseContainerC2S {
  window_id : Int // Window ID to close
}

///|
pub impl @mc.Packet for CloseContainerC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for CloseContainerC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.window_id)
}

///|
pub impl @mc.Packet for CloseContainerC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { window_id: @types.read_varint(buf) }
}
