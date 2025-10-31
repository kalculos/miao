///|
/// Set Experience packet (0x60)
/// Sets player experience
struct SetExperienceS2C {
  experience_bar : Float // Experience bar progress
  level : Int // Experience level
  total_experience : Int // Total experience
}
///|
impl @mc.Packet for SetExperienceS2C with clientbound(self) {
  true
}