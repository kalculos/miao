///|
/// Update Sign packet (0x3B)
/// Updates sign text
struct UpdateSignC2S {
  location : @types.Position // Sign position
  is_front_text : Bool // Whether editing front text
  line1 : String // Line 1 text
  line2 : String // Line 2 text
  line3 : String // Line 3 text
  line4 : String // Line 4 text
}

///|
impl @mc.Packet for UpdateSignC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for UpdateSignC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_position(buf, self.location)
  @types.write_bool(buf, self.is_front_text)
  @types.write_string(buf, self.line1)
  @types.write_string(buf, self.line2)
  @types.write_string(buf, self.line3)
  @types.write_string(buf, self.line4)
}

///|
impl @mc.Packet for UpdateSignC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let location = @types.read_position(buf)
  let is_front_text = @types.read_bool(buf)
  let line1 = @types.read_string(buf)
  let line2 = @types.read_string(buf)
  let line3 = @types.read_string(buf)
  let line4 = @types.read_string(buf)
  { location, is_front_text, line1, line2, line3, line4 }
}

