///|
/// Change Difficulty packet (0x0A)
/// Changes game difficulty
struct ChangeDifficultyS2C {
  difficulty : Byte // Difficulty level
  difficulty_locked : Bool // Whether difficulty is locked
}
///|
impl @mc.Packet for ChangeDifficultyS2C with clientbound(self) {
  true
}