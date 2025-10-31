///|
/// Open Book packet (0x33)
/// Opens book interface
struct OpenBookS2C {
  hand : Int // Hand holding book, enum(0=main, 1=off)
}

///|
impl @mc.Packet for OpenBookS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for OpenBookS2C with serialize(self, buf : &@buffer.Buffer) {
  @types.write_varint(buf, self.hand)
}

///|
impl @mc.Packet for OpenBookS2C with deserialize(buf : &@buffer.Buffer) {
  let hand = @types.read_varint(buf)
  { hand, }
}
