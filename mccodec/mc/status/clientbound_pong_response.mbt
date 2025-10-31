///|
/// Pong Response packet (0x01)  
/// Sent in response to Ping Request, echoes back the timestamp
struct PongResponseS2C {
  timestamp : Int64
}

///|
impl @mc.Packet for PongResponseS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for PongResponseS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int64(self.timestamp)
}

///|
impl @mc.Packet for PongResponseS2C with deserialize(buf : &@buffer.Buffer) {
  { timestamp: buf.read_int64().unwrap() }
}
