///|
/// Pong Response packet (0x01)  
/// Sent in response to Ping Request, echoes back the timestamp
pub(all) struct PongResponseS2C {
  timestamp : Int64
}

///|
pub impl @mc.Packet for PongResponseS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for PongResponseS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int64(self.timestamp)
}

///|
pub impl @mc.Packet for PongResponseS2C with deserialize(buf : &@buffer.Buffer) {
  { timestamp: buf.read_int64() }
}
