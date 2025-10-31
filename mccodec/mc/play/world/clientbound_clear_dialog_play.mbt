///|
/// Clear Dialog (play) packet (0x84)
/// Clears dialog screen
struct ClearDialogPlayS2C {}
///|
impl @mc.Packet for ClearDialogPlayS2C with clientbound(self) {
  true
}