///|
/// Status Request packet (0x00)
/// Requests server status information, has no fields
struct StatusRequestC2S {}

///|
impl @mc.Packet for StatusRequestC2S with clientbound(self) {
  false
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
