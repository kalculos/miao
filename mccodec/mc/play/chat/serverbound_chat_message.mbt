///|
/// Chat Message packet (0x08)
/// Sends chat message
/// TODO: (de)serialize
struct ChatMessageC2S {
  message : String // Chat message content
  timestamp : Int64 // Message timestamp
  salt : Int64 // Random salt
  signature : Array[Byte]? // Message signature
  message_count : Int // Message count
  acknowledged : Array[Byte] // Acknowledged messages, TODO: BitSet type
  checksum: Array[Byte] // Checksum
}

///|
impl @mc.Packet for ChatMessageC2S with clientbound(self) {
  false
}

