///|
/// Ping Request (play) packet (0x25)
/// Sends ping to server
struct PingRequestPlayC2S {
  payload : Int64 // Ping payload
}

///|
impl @mc.Packet for PingRequestPlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PingRequestPlayC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int64(self.payload)
}

///|
impl @mc.Packet for PingRequestPlayC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { payload: buf.read_int64().unwrap() }
}

