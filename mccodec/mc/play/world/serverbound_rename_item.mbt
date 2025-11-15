///|
/// Rename Item packet (0x2F)
/// Renames item in anvil
pub(all) struct RenameItemC2S {
  item_name : String // New item name
}

///|
pub impl @mc.Packet for RenameItemC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for RenameItemC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.item_name)
}

///|
pub impl @mc.Packet for RenameItemC2S with deserialize(buf : &@buffer.Buffer) {
  { item_name: @types.read_string(buf) }
}
