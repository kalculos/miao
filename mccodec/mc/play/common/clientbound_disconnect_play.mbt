///|
/// Disconnect (play) packet (0x1C)
/// Disconnects player during play
struct DisconnectPlayS2C {
  reason : String // JSON disconnect reason
}
///|
impl @mc.Packet for DisconnectPlayS2C with clientbound(self) {
  true
}