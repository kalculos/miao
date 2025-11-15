///|
/// Ping Request packet (0x01)
/// Requests a ping to measure latency, contains timestamp
pub(all) struct PingRequestC2S {
  timestamp : Int64
}

///|
pub impl @mc.Packet for PingRequestC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PingRequestC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int64(self.timestamp)
}

///|
pub impl @mc.Packet for PingRequestC2S with deserialize(buf : &@buffer.Buffer) {
  { timestamp: buf.read_int64() }
}
