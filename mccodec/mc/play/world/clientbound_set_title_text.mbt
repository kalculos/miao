///|
/// Set Title Text packet (0x6B)
/// Sets title text
pub(all) struct SetTitleTextS2C {
  title_text : String // Title text
}

///|
pub impl @mc.Packet for SetTitleTextS2C with clientbound(_) {
  true
}
