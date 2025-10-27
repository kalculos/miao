///|
/// Show Dialog (configuration) packet (0x12)
/// Shows custom dialog screen to client
struct ShowDialogConfigS2C {
  dialog : @nbt.NBTTag // NBT data for dialog definition
}

///|
impl @mc.Packet for ShowDialogConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ShowDialogConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // TODO: Implement NBT writing
  panic()
}

///|
impl @mc.Packet for ShowDialogConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  // TODO: Implement NBT reading
  panic()
}

