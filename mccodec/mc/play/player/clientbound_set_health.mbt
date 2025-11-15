///|
/// Set Health packet (0x61)
/// Sets player health
pub(all) struct SetHealthS2C {
  health : Float // Player health
  food : Int // Food level
  food_saturation : Float // Food saturation
}

///|
pub impl @mc.Packet for SetHealthS2C with clientbound(_) {
  true
}
