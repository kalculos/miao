///|
/// Close Container packet (0x12)
/// Closes inventory window
struct CloseContainerC2S {
  window_id : Int // Window ID to close
}

///|
impl @mc.Packet for CloseContainerC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CloseContainerC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.window_id)
}

///|
impl @mc.Packet for CloseContainerC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { window_id: @types.read_varint(buf) }
}

