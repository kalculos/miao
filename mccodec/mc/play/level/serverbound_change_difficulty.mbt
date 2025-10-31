///|
/// Change Difficulty packet (0x03)
/// Requests difficulty change
struct ChangeDifficultyC2S {
  new_difficulty : Int // Requested difficulty, TODO: enum
}

///|
impl @mc.Packet for ChangeDifficultyC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChangeDifficultyC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.new_difficulty)
}

///|
impl @mc.Packet for ChangeDifficultyC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { new_difficulty: @types.read_varint(buf) }
}

