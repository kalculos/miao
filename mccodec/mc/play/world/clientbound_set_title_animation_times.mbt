///|
/// Set Title Animation Times packet (0x6C)
/// Sets title animation timing
pub(all) struct SetTitleAnimationTimesS2C {
  fade_in : Int // Fade in time in ticks
  stay : Int // Stay time in ticks
  fade_out : Int // Fade out time in ticks
}
///|
pub impl @mc.Packet for SetTitleAnimationTimesS2C with clientbound(_) {
  true
}