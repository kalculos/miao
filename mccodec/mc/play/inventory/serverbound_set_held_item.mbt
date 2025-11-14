///|
/// Set Held Item (serverbound) packet (0x34)
/// Changes held item slot
pub(all) struct SetHeldItemC2S {
  slot : Int16 // Hotbar slot (0-8)
}

///|
pub impl @mc.Packet for SetHeldItemC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for SetHeldItemC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int16(self.slot)
}

///|
pub impl @mc.Packet for SetHeldItemC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { slot: buf.read_int16() }
}

