///|
/// Place Recipe packet (0x26)
/// Places recipe in crafting grid
struct PlaceRecipeC2S {
  window_id : Int // Window ID
  recipe : String // Recipe identifier
  make_all : Bool // Make all possible
}

///|
impl @mc.Packet for PlaceRecipeC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PlaceRecipeC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_int(self.window_id)
  @types.write_string(buf, self.recipe)
  @types.write_bool(buf, self.make_all)
}

///|
impl @mc.Packet for PlaceRecipeC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let window_id = buf.read_int()
  let recipe = @types.read_string(buf)
  let make_all = @types.read_bool(buf)
  { window_id, recipe, make_all }
}

