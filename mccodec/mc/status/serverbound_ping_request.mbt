///|
/// Ping Request packet (0x01)
/// Requests a ping to measure latency, contains timestamp
struct PingRequestC2S {
  timestamp : Int64
}

///|
impl @mc.Packet for PingRequestC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PingRequestC2S with serialize(self, buf : &@buffer.Buffer) {
  buf.write_int64(self.timestamp)
}

///|
impl @mc.Packet for PingRequestC2S with deserialize(buf : &@buffer.Buffer) {
  { timestamp: buf.read_int64().unwrap() }
}
