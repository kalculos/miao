///|
/// Change Difficulty packet (0x0A)
/// Changes game difficulty
pub(all) struct ChangeDifficultyS2C {
  difficulty : Byte // Difficulty level
  difficulty_locked : Bool // Whether difficulty is locked
}
///|
pub impl @mc.Packet for ChangeDifficultyS2C with clientbound(_) {
  true
}