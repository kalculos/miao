///|
/// Set Cursor Item packet (0x59)
/// Sets cursor item
pub(all) struct SetCursorItemS2C {
  slot_data : @types.Slot // Item data
}

///|
pub impl @mc.Packet for SetCursorItemS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for SetCursorItemS2C with serialize(self, buf : &@buffer.Buffer) {
  @types.write_slot(buf, self.slot_data)
}

///|
pub impl @mc.Packet for SetCursorItemS2C with deserialize(buf : &@buffer.Buffer) {
  let slot_data = @types.read_slot(buf)
  { slot_data, }
}
