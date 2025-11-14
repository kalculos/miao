///|
/// Set Held Item (clientbound) packet (0x62)
/// Sets held item slot
pub(all) struct SetHeldItemS2C {
  slot : Int // Selected slot
}

///|
pub impl @mc.Packet for SetHeldItemS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for SetHeldItemS2C with serialize(self, buf : &@buffer.Buffer) {
  @types.write_varint(buf, self.slot)
}

///|
pub impl @mc.Packet for SetHeldItemS2C with deserialize(buf : &@buffer.Buffer) {
  let slot = @types.read_varint(buf)
  { slot, }
}
