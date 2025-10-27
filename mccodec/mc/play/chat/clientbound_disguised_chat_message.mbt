///|
/// Disguised Chat Message packet (0x1D)
/// Chat message that appears as system message
struct DisguisedChatMessageS2C {
  message : String // Chat message content
  chat_type : Int // Chat type ID
  sender_name : String // Display name of sender
  target_name : String? // Target name (for targeted messages)
}
///|
impl @mc.Packet for DisguisedChatMessageS2C with clientbound(self) {
  true
}