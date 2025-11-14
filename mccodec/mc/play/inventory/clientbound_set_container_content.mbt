///|
/// Set Container Content packet (0x12)
/// Sets all slots in container
pub(all) struct SetContainerContentS2C {
  window_id : Int // Window ID
  state_id : Int // State ID
  slots : FixedArray[@types.Slot] // Slot data (ItemStack format)
  carried_item : @types.Slot // Item being carried
}

///|
pub impl @mc.Packet for SetContainerContentS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for SetContainerContentS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.window_id)
  @types.write_varint(buf, self.state_id)
  @types.write_prefix_array(buf, self.slots, @types.write_slot)
  @types.write_slot(buf, self.carried_item)
}

///|
pub impl @mc.Packet for SetContainerContentS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let window_id = @types.read_varint(buf)
  let state_id = @types.read_varint(buf)
  let slots = @types.read_prefix_array(buf, @types.read_slot)
  let carried_item = @types.read_slot(buf)
  { window_id, state_id, slots, carried_item }
}
