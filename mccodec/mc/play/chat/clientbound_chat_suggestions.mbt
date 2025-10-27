///|
/// Chat Suggestions packet (0x17)
/// Provides chat suggestions
struct ChatSuggestionsS2C {
  action : Int // Action (0=add, 1=remove, 2=set)
  entries : Array[String] // Chat suggestion entries
}
///|
impl @mc.Packet for ChatSuggestionsS2C with clientbound(self) {
  true
}