///|
/// Server Links packet (0x82)
/// Server links for pause menu
struct ServerLinksS2C {
  links : Array[(String, String)] // (Label, URL) pairs
}
///|
impl @mc.Packet for ServerLinksS2C with clientbound(self) {
  true
}