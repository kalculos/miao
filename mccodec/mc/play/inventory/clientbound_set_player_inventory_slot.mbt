///|
/// Set Player Inventory Slot packet (0x65)
/// Sets player inventory slot
struct SetPlayerInventorySlotS2C {
  slot : Int // Slot index
  slot_data : @types.Slot // Item data
}

///|
impl @mc.Packet for SetPlayerInventorySlotS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for SetPlayerInventorySlotS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.slot)
  @types.write_slot(buf, self.slot_data)
}

///|
impl @mc.Packet for SetPlayerInventorySlotS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let slot = @types.read_varint(buf)
  let slot_data = @types.read_slot(buf)
  { slot, slot_data }
}
