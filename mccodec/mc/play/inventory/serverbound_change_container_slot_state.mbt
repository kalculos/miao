///|
/// Change Container Slot State packet (0x13)
/// Changes container slot state
pub(all) struct ChangeContainerSlotStateC2S {
  slot_id : Int // Slot ID
  window_id : Int // Window ID
  state : Bool // New state
}

///|
pub impl @mc.Packet for ChangeContainerSlotStateC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ChangeContainerSlotStateC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.slot_id)
  @types.write_varint(buf, self.window_id)
  @types.write_bool(buf, self.state)
}

///|
pub impl @mc.Packet for ChangeContainerSlotStateC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let slot_id = @types.read_varint(buf)
  let window_id = @types.read_varint(buf)
  let state = @types.read_bool(buf)
  { slot_id, window_id, state }
}
