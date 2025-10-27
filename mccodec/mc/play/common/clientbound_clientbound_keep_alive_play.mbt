///|
/// Clientbound Keep Alive (play) packet (0x26)
/// Keep connection alive
struct ClientboundKeepAlivePlayS2C {
  keep_alive_id : Int64 // Keep alive ID
}
///|
impl @mc.Packet for ClientboundKeepAlivePlayS2C with clientbound(self) {
  true
}