///|
/// Player Abilities (serverbound) packet (0x27)
/// Updates player ability flags
pub(all) struct PlayerAbilitiesC2S {
  flags : Byte // Ability flags (flying bit = 0x02)
}

///|
pub impl @mc.Packet for PlayerAbilitiesC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PlayerAbilitiesC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_byte(self.flags)
}

///|
pub impl @mc.Packet for PlayerAbilitiesC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { flags: buf.read_byte() }
}
