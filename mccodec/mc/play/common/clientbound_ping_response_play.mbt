///|
/// Ping Response (play) packet (0x37)
/// Server ping response
struct PingResponsePlayS2C {
  payload : Int64 // Ping payload
}
///|
impl @mc.Packet for PingResponsePlayS2C with clientbound(self) {
  true
}