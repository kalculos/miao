///|
/// Ping (play) packet (0x36)
/// Server ping packet
struct PingPlayS2C {
  id : Int // Ping ID
}
///|
impl @mc.Packet for PingPlayS2C with clientbound(self) {
  true
}