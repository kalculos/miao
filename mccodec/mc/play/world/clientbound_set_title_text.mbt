///|
/// Set Title Text packet (0x6B)
/// Sets title text
struct SetTitleTextS2C {
  title_text : String // Title text
}
///|
impl @mc.Packet for SetTitleTextS2C with clientbound(self) {
  true
}