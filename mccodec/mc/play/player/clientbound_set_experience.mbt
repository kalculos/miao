///|
/// Set Experience packet (0x60)
/// Sets player experience
pub(all) struct SetExperienceS2C {
  experience_bar : Float // Experience bar progress
  level : Int // Experience level
  total_experience : Int // Total experience
}

///|
pub impl @mc.Packet for SetExperienceS2C with clientbound(_) {
  true
}
