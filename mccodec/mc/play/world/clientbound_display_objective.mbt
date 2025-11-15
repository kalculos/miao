///|
/// Display Objective packet (0x5B)
/// Displays scoreboard objective
pub(all) struct DisplayObjectiveS2C {
  position : Byte // Display position
  score_name : String // Objective name
}

///|
pub impl @mc.Packet for DisplayObjectiveS2C with clientbound(_) {
  true
}
