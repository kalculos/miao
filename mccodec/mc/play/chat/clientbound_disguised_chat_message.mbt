///|
/// Disguised Chat Message packet (0x1D)
/// Chat message that appears as system message
struct DisguisedChatMessageS2C {
  message : String // Chat message content, TODO: Text Component
  chat_type : @types.Holder[@types.ChatType] // Chat type ID
  sender_name : String // Display name of sender, TODO: Text Component
  target_name : String? // Target name (for targeted messages), TODO: Text Component
}
///|
impl @mc.Packet for DisguisedChatMessageS2C with clientbound(self) {
  true
}

impl @mc.Packet for DisguisedChatMessageS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.message)
  @types.write_holder(buf, self.chat_type, @types.write_chat_type)
  @types.write_string(buf, self.sender_name)
  @types.write_optional(buf, self.target_name, @types.write_string)
}

impl @mc.Packet for DisguisedChatMessageS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let message = @types.read_string(buf)
  let chat_type = @types.read_holder(buf, @types.read_chat_type)
  let sender_name = @types.read_string(buf)
  let target_name = @types.read_optional(buf, @types.read_string)
  { message, chat_type, sender_name, target_name }
}