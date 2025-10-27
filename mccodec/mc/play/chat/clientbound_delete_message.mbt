///|
/// Delete Message packet (0x1B)
/// Deletes chat message
struct DeleteMessageS2C {
  message_id : Int // Message ID to delete
  signature : Array[Byte] // Message signature
}
///|
impl @mc.Packet for DeleteMessageS2C with clientbound(self) {
  true
}