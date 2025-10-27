///|
/// Player Chat Message packet (0x3A)
/// Player chat message
struct PlayerChatMessageS2C {
  sender : String // Sender UUID
  index : Int // Message index
  message_signature : Array[Byte]? // Message signature
  message : String // Message content
  timestamp : Int64 // Message timestamp
  salt : Int64 // Random salt
  previous_messages : Array[(String, Array[Byte]?)] // Previous message signatures
  other_player_message : String? // Other player message
  chat_type : Int // Chat type
  sender_name : String // Sender display name
  target_name : String? // Target display name
}
///|
impl @mc.Packet for PlayerChatMessageS2C with clientbound(self) {
  true
}