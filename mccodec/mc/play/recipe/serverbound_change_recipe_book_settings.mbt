///|
/// Change Recipe Book Settings packet (0x2D)
/// Changes recipe book settings
pub(all) struct ChangeRecipeBookSettingsC2S {
  book_id : Int // Book type, enum(0=crafting, 1=furnace, 2=blast_furnace, 3=smoker)
  book_open : Bool // Whether book is open
  filter_active : Bool // Whether filter is active
}

///|
pub impl @mc.Packet for ChangeRecipeBookSettingsC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ChangeRecipeBookSettingsC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.book_id)
  @types.write_bool(buf, self.book_open)
  @types.write_bool(buf, self.filter_active)
}

///|
pub impl @mc.Packet for ChangeRecipeBookSettingsC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let book_id = @types.read_varint(buf)
  let book_open = @types.read_bool(buf)
  let filter_active = @types.read_bool(buf)
  { book_id, book_open, filter_active }
}
