///|
/// Select Trade packet (0x32)
/// Selects villager trade
struct SelectTradeC2S {
  selected_slot : Int // Selected trade slot
}

///|
impl @mc.Packet for SelectTradeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SelectTradeC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.selected_slot)
}

///|
impl @mc.Packet for SelectTradeC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { selected_slot: @types.read_varint(buf) }
}

