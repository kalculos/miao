///|
/// Transfer (play) packet (0x7A)
/// Transfers to another server
struct TransferPlayS2C {
  host : String // Target server host
  port : Int // Target server port
}
///|
impl @mc.Packet for TransferPlayS2C with clientbound(self) {
  true
}