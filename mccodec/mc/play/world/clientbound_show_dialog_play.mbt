///|
/// Show Dialog (play) packet (0x85)
/// Shows dialog screen
pub(all) struct ShowDialogPlayS2C {
  dialog : String // Dialog NBT data
}

///|
pub impl @mc.Packet for ShowDialogPlayS2C with clientbound(_) {
  true
}
