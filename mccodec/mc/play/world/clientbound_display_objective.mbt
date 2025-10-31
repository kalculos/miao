///|
/// Display Objective packet (0x5B)
/// Displays scoreboard objective
struct DisplayObjectiveS2C {
  position : Byte // Display position
  score_name : String // Objective name
}
///|
impl @mc.Packet for DisplayObjectiveS2C with clientbound(self) {
  true
}