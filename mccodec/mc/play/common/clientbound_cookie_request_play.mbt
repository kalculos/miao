///|
/// Cookie Request (play) packet (0x15)
/// Requests a stored cookie
struct CookieRequestPlayS2C {
  key : String // Cookie identifier
}
///|
impl @mc.Packet for CookieRequestPlayS2C with clientbound(self) {
  true
}