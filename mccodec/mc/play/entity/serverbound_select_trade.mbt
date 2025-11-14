///|
/// Select Trade packet (0x32)
/// Selects villager trade
pub(all) struct SelectTradeC2S {
  selected_slot : Int // Selected trade slot
}

///|
pub impl @mc.Packet for SelectTradeC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for SelectTradeC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.selected_slot)
}

///|
pub impl @mc.Packet for SelectTradeC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { selected_slot: @types.read_varint(buf) }
}

