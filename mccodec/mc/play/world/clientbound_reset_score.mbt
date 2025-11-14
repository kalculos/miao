///|
/// Reset Score packet (0x48)
/// Resets scoreboard score
pub(all) struct ResetScoreS2C {
  entity_name : String // Entity name
  objective_name : String? // Objective name (null for all)
}
///|
pub impl @mc.Packet for ResetScoreS2C with clientbound(_) {
  true
}