///|
/// Set Subtitle Text packet (0x69)
/// Sets subtitle text
struct SetSubtitleTextS2C {
  subtitle_text : String // Subtitle text
}
///|
impl @mc.Packet for SetSubtitleTextS2C with clientbound(self) {
  true
}