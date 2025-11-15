///|
/// Set Container Slot packet (0x14)
/// Updates single container slot
pub(all) struct SetContainerSlotS2C {
  window_id : Int // Window ID
  state_id : Int // State ID
  slot : Int16 // Slot index
  slot_data : @types.Slot // Slot item data
}

///|
pub impl @mc.Packet for SetContainerSlotS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for SetContainerSlotS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.window_id)
  @types.write_varint(buf, self.state_id)
  buf.write_int16(self.slot)
  @types.write_slot(buf, self.slot_data)
}

///|
pub impl @mc.Packet for SetContainerSlotS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let window_id = @types.read_varint(buf)
  let state_id = @types.read_varint(buf)
  let slot = buf.read_int16()
  let slot_data = @types.read_slot(buf)
  { window_id, state_id, slot, slot_data }
}
