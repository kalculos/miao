///|
/// Update Score packet (0x67)
/// Updates scoreboard score
struct UpdateScoreS2C {
  entity_name : String // Entity name
  objective_name : String // Objective name
  value : Int // Score value
  display_name : String? // Display name
  number_format : String? // Number format
}
///|
impl @mc.Packet for UpdateScoreS2C with clientbound(self) {
  true
}