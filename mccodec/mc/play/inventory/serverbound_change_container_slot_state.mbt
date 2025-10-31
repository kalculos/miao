///|
/// Change Container Slot State packet (0x13)
/// Changes container slot state
struct ChangeContainerSlotStateC2S {
  slot_id : Int // Slot ID
  window_id : Int // Window ID
  state : Bool // New state
}

///|
impl @mc.Packet for ChangeContainerSlotStateC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChangeContainerSlotStateC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.slot_id)
  @types.write_varint(buf, self.window_id)
  @types.write_bool(buf, self.state)
}

///|
impl @mc.Packet for ChangeContainerSlotStateC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let slot_id = @types.read_varint(buf)
  let window_id = @types.read_varint(buf)
  let state = @types.read_bool(buf)
  { slot_id, window_id, state }
}

