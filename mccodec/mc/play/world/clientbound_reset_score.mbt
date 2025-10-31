///|
/// Reset Score packet (0x48)
/// Resets scoreboard score
struct ResetScoreS2C {
  entity_name : String // Entity name
  objective_name : String? // Objective name (null for all)
}
///|
impl @mc.Packet for ResetScoreS2C with clientbound(self) {
  true
}