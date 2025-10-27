///|
/// Rename Item packet (0x2F)
/// Renames item in anvil
struct RenameItemC2S {
  item_name : String // New item name
}

///|
impl @mc.Packet for RenameItemC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for RenameItemC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.item_name)
}

///|
impl @mc.Packet for RenameItemC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { item_name: @types.read_string(buf) }
}

