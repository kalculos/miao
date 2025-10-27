///|
/// Set Title Animation Times packet (0x6C)
/// Sets title animation timing
struct SetTitleAnimationTimesS2C {
  fade_in : Int // Fade in time in ticks
  stay : Int // Stay time in ticks
  fade_out : Int // Fade out time in ticks
}
///|
impl @mc.Packet for SetTitleAnimationTimesS2C with clientbound(self) {
  true
}