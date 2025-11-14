///|
/// Set Subtitle Text packet (0x69)
/// Sets subtitle text
pub(all) struct SetSubtitleTextS2C {
  subtitle_text : String // Subtitle text
}
///|
pub impl @mc.Packet for SetSubtitleTextS2C with clientbound(_) {
  true
}