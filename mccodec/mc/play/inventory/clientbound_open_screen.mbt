///|
/// Open Screen packet (0x34)
/// Opens GUI screen
struct OpenScreenS2C {
  window_id : Int // Window ID
  window_type : Int // Window type
  window_title : String // Window title, TODO: Text Component
}

///|
impl @mc.Packet for OpenScreenS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for OpenScreenS2C with serialize(self, buf : &@buffer.Buffer) {
  @types.write_varint(buf, self.window_id)
  @types.write_varint(buf, self.window_type)
  @types.write_string(buf, self.window_title)
}

///|
impl @mc.Packet for OpenScreenS2C with deserialize(buf : &@buffer.Buffer) {
  let window_id = @types.read_varint(buf)
  let window_type = @types.read_varint(buf)
  let window_title = @types.read_string(buf)
  { window_id, window_type, window_title }
}
