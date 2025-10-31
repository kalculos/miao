///|
/// Pong (configuration) packet (0x05)
/// Response to server's ping packet
struct PongConfigC2S {
  id : Int // Must match ping ID from server
}

///|
impl @mc.Packet for PongConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PongConfigC2S with serialize(self, buf : &@buffer.Buffer) {
  buf.write_int(self.id)
}

///|
impl @mc.Packet for PongConfigC2S with deserialize(buf : &@buffer.Buffer) {
  { id: buf.read_int() }
}

