///|
/// Player Input packet (0x2A)
/// Player input controls
struct PlayerInputC2S {
  flags : Byte // Input flags, TODO: bit mask
}

///|
impl @mc.Packet for PlayerInputC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlayerInputC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for PlayerInputC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let flags = buf.read_byte().unwrap()
  {  flags, }
}

