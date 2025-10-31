///|
/// Set Seen Recipe packet (0x2E)
/// Marks recipe as seen
struct SetSeenRecipeC2S {
  recipe_id : Int // Recipe identifier
}

///|
impl @mc.Packet for SetSeenRecipeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetSeenRecipeC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.recipe_id)
}

///|
impl @mc.Packet for SetSeenRecipeC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { recipe_id: @types.read_varint(buf) }
}

