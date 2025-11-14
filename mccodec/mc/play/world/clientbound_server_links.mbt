///|
/// Server Links packet (0x82)
/// Server links for pause menu
pub(all) struct ServerLinksS2C {
  links : Array[(String, String)] // (Label, URL) pairs
}
///|
pub impl @mc.Packet for ServerLinksS2C with clientbound(_) {
  true
}