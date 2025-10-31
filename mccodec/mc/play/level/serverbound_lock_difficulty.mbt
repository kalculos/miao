///|
/// Lock Difficulty packet (0x1C)
/// Locks difficulty setting
struct LockDifficultyC2S {
  locked : Bool // Whether to lock difficulty
}

///|
impl @mc.Packet for LockDifficultyC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for LockDifficultyC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_bool(buf, self.locked)
}

///|
impl @mc.Packet for LockDifficultyC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { locked: @types.read_bool(buf) }
}

