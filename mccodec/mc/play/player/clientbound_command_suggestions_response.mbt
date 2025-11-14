///|
/// Command Suggestions Response packet (0x0F)
/// Response to tab completion request
pub(all) struct CommandSuggestionsResponseS2C {
  id : Int // Request ID
  start : Int // Start of replacement range
  length : Int // Length of replacement range
  matches : Array[(String, String?)] // (Match, Tooltip) entries
}
///|
pub impl @mc.Packet for CommandSuggestionsResponseS2C with clientbound(_) {
  true
}