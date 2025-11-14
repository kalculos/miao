///|
/// Show Dialog (configuration) packet (0x12)
/// Shows custom dialog screen to client
pub(all) struct ShowDialogConfigS2C {
  dialog : @nbt.NBTTag // NBT data for dialog definition
}

///|
pub impl @mc.Packet for ShowDialogConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ShowDialogConfigS2C with serialize(
  _,
  _ : &@buffer.Buffer,
) {
  // TODO: Implement NBT writing
  panic()
}

///|
pub impl @mc.Packet for ShowDialogConfigS2C with deserialize(
  _ : &@buffer.Buffer,
) {
  // TODO: Implement NBT reading
  panic()
}

