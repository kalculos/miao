///|
/// Set Container Property packet (0x13)
/// Updates container property
pub(all) struct SetContainerPropertyS2C {
  window_id : Int // Window ID
  property : Int16 // Property ID
  value : Int16 // Property value
}

///|
pub impl @mc.Packet for SetContainerPropertyS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for SetContainerPropertyS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.window_id)
  buf.write_int16(self.property)
  buf.write_int16(self.value)
}

///|
pub impl @mc.Packet for SetContainerPropertyS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let window_id = @types.read_varint(buf)
  let property = buf.read_int16()
  let value = buf.read_int16()
  { window_id, property, value }
}
