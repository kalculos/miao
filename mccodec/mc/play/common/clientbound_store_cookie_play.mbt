///|
/// Store Cookie (play) packet (0x71)
/// Stores cookie on client
struct StoreCookiePlayS2C {
  key : String // Cookie key
  payload : Array[Byte] // Cookie payload
}
///|
impl @mc.Packet for StoreCookiePlayS2C with clientbound(self) {
  true
}