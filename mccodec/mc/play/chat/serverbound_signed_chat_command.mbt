///|
/// Signed Chat Command packet (0x07)
/// Sends signed chat command
/// TODO: (de)serialize
struct SignedChatCommandC2S {
  command : String // Command text
  timestamp : Int64 // Command timestamp
  salt : Int64 // Random salt
  argument_signatures : FixedArray[(String, Array[Byte])] // Argument signatures
  message_count : Int // Message count
  acknowledged : Byte // Acknowledged messages, TODO: BitSet type
  checksum: Byte // Checksum
}

///|
impl @mc.Packet for SignedChatCommandC2S with clientbound(self) {
  false
}

