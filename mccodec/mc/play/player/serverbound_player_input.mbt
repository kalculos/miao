///|
/// Player Input packet (0x2A)
/// Player input controls
pub(all) struct PlayerInputC2S {
  flags : Byte // Input flags, TODO: bit mask
}

///|
pub impl @mc.Packet for PlayerInputC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PlayerInputC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_byte(self.flags)
}

///|
pub impl @mc.Packet for PlayerInputC2S with deserialize(buf : &@buffer.Buffer) {
  let flags = buf.read_byte()
  { flags, }
}
