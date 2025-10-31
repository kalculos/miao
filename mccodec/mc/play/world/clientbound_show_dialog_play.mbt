///|
/// Show Dialog (play) packet (0x85)
/// Shows dialog screen
struct ShowDialogPlayS2C {
  dialog : String // Dialog NBT data
}
///|
impl @mc.Packet for ShowDialogPlayS2C with clientbound(self) {
  true
}