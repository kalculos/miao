///|
/// Set Player Movement Flags packet (0x20)
/// Sets player movement state flags
pub(all) struct SetPlayerMovementFlagsC2S {
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
pub impl @mc.Packet for SetPlayerMovementFlagsC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for SetPlayerMovementFlagsC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_byte(self.on_ground)
}

///|
pub impl @mc.Packet for SetPlayerMovementFlagsC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { on_ground: buf.read_byte() }
}
