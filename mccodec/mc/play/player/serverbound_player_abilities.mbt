///|
/// Player Abilities (serverbound) packet (0x27)
/// Updates player ability flags
struct PlayerAbilitiesC2S {
  flags : Byte // Ability flags (flying bit = 0x02)
}

///|
impl @mc.Packet for PlayerAbilitiesC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerAbilitiesC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for PlayerAbilitiesC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { flags: buf.read_byte().unwrap() }
}

