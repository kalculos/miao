///|
/// System Chat Message packet (0x72)
/// System chat message
struct SystemChatMessageS2C {
  content : String // Message content
  overlay : Bool // Display as overlay
}
///|
impl @mc.Packet for SystemChatMessageS2C with clientbound(self) {
  true
}