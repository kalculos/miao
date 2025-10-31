///|
/// Set Cursor Item packet (0x59)
/// Sets cursor item
struct SetCursorItemS2C {
  slot_data : @types.Slot // Item data
}

///|
impl @mc.Packet for SetCursorItemS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for SetCursorItemS2C with serialize(self, buf : &@buffer.Buffer) {
  @types.write_slot(buf, self.slot_data)
}

///|
impl @mc.Packet for SetCursorItemS2C with deserialize(buf : &@buffer.Buffer) {
  let slot_data = @types.read_slot(buf)
  { slot_data, }
}
