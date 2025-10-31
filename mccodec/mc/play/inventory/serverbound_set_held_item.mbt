///|
/// Set Held Item (serverbound) packet (0x34)
/// Changes held item slot
struct SetHeldItemC2S {
  slot : Int16 // Hotbar slot (0-8)
}

///|
impl @mc.Packet for SetHeldItemC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetHeldItemC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int16(self.slot)
}

///|
impl @mc.Packet for SetHeldItemC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { slot: buf.read_int16() }
}

