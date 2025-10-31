///|
/// Close Container packet (0x11)
/// Closes inventory interface
struct CloseContainerS2C {
  window_id : Int // Window ID
}

///|
impl @mc.Packet for CloseContainerS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for CloseContainerS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.window_id)
}

///|
impl @mc.Packet for CloseContainerS2C with deserialize(buf : &@buffer.Buffer) {
  let window_id = @types.read_varint(buf)
  { window_id, }
}
