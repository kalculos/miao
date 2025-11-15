///|
/// Open Sign Editor packet (0x35)
/// Opens sign editing interface
pub(all) struct OpenSignEditorS2C {
  location : @types.Position // Sign position
  is_front_text : Bool // Whether editing front text
}

///|
pub impl @mc.Packet for OpenSignEditorS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for OpenSignEditorS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_position(buf, self.location)
  @types.write_bool(buf, self.is_front_text)
}

///|
pub impl @mc.Packet for OpenSignEditorS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let location = @types.read_position(buf)
  let is_front_text = @types.read_bool(buf)
  { location, is_front_text }
}
