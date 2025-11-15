///|
/// Swing Arm packet (0x3C)
/// Swings player arm
pub(all) struct SwingArmC2S {
  hand : Int // Hand enum(0=main, 1=off)
}

///|
pub impl @mc.Packet for SwingArmC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for SwingArmC2S with serialize(self, buf : &@buffer.Buffer) {
  @types.write_varint(buf, self.hand)
}

///|
pub impl @mc.Packet for SwingArmC2S with deserialize(buf : &@buffer.Buffer) {
  { hand: @types.read_varint(buf) }
}
