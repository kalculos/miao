///|
/// Status Request packet (0x00)
/// Requests server status information, has no fields
struct StatusRequestC2S {}

///|
impl @mc.Packet for StatusRequestC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for StatusRequestC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for StatusRequestC2S with deserialize(buf : &@bytebuf.ByteBuf) {
  StatusRequestC2S::{  }
}

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
impl @mc.Packet for PingRequestC2S with serialize(self, buf : &@bytebuf.ByteBuf) {
  buf.write_int64(self.timestamp)
}

///|
impl @mc.Packet for PingRequestC2S with deserialize(buf : &@bytebuf.ByteBuf) {
  { timestamp: buf.read_int64().unwrap() }
}
