///|
/// Set Tab List Header And Footer packet (0x73)
/// Sets tab list header/footer
pub(all) struct SetTabListHeaderAndFooterS2C {
  header : String // Tab list header
  footer : String // Tab list footer
}
///|
pub impl @mc.Packet for SetTabListHeaderAndFooterS2C with clientbound(_) {
  true
}