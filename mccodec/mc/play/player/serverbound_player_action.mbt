///|
/// Player Action packet (0x28)
/// Player performs block action
pub(all) struct PlayerActionC2S {
  status : Int // Action status, TODO: enum
  location : @types.Position // Block position
  face : Byte // Block face, TODO: enum
  sequence : Int // Action sequence
}

///|
pub impl @mc.Packet for PlayerActionC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PlayerActionC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.status)
  @types.write_position(buf, self.location)
  buf.write_byte(self.face)
  @types.write_varint(buf, self.sequence)
}

///|
pub impl @mc.Packet for PlayerActionC2S with deserialize(buf : &@buffer.Buffer) {
  let status = @types.read_varint(buf)
  let location = @types.read_position(buf)
  let face = buf.read_byte()
  let sequence = @types.read_varint(buf)
  { status, location, face, sequence }
}
