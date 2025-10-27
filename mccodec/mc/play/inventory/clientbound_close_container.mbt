///|
/// Close Container packet (0x11)
/// Closes inventory interface
struct CloseContainerS2C {
  window_id : Byte // Window ID
}
///|
impl @mc.Packet for CloseContainerS2C with clientbound(self) {
  true
}