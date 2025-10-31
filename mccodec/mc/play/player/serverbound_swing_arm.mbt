///|
/// Swing Arm packet (0x3C)
/// Swings player arm
struct SwingArmC2S {
  hand : Int // Hand enum(0=main, 1=off)
}

///|
impl @mc.Packet for SwingArmC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SwingArmC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.hand)
}

///|
impl @mc.Packet for SwingArmC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { hand: @types.read_varint(buf) }
}

