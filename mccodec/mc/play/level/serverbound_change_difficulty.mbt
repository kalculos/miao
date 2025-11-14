///|
/// Change Difficulty packet (0x03)
/// Requests difficulty change
pub(all) struct ChangeDifficultyC2S {
  new_difficulty : Int // Requested difficulty, TODO: enum
}

///|
pub impl @mc.Packet for ChangeDifficultyC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ChangeDifficultyC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.new_difficulty)
}

///|
pub impl @mc.Packet for ChangeDifficultyC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { new_difficulty: @types.read_varint(buf) }
}

