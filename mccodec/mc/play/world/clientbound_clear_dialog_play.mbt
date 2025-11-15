///|
/// Clear Dialog (play) packet (0x84)
/// Clears dialog screen
pub(all) struct ClearDialogPlayS2C {}

///|
pub impl @mc.Packet for ClearDialogPlayS2C with clientbound(_) {
  true
}
