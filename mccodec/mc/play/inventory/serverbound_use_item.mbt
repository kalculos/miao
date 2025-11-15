///|
/// Use Item packet (0x40)
/// Uses held item
pub(all) struct UseItemC2S {
  hand : Int // Hand used enum(0=main, 1=off)
  sequence : Int // Action sequence
  yaw : Float // Player yaw
  pitch : Float // Player pitch
}

///|
pub impl @mc.Packet for UseItemC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for UseItemC2S with serialize(self, buf : &@buffer.Buffer) {
  @types.write_varint(buf, self.hand)
  @types.write_varint(buf, self.sequence)
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
}

///|
pub impl @mc.Packet for UseItemC2S with deserialize(buf : &@buffer.Buffer) {
  let hand = @types.read_varint(buf)
  let sequence = @types.read_varint(buf)
  let yaw = buf.read_float()
  let pitch = buf.read_float()
  { hand, sequence, yaw, pitch }
}
