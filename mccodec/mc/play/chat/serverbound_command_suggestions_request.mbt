///|
/// Command Suggestions Request packet (0x0E)
/// Requests tab completion
pub(all) struct CommandSuggestionsRequestC2S {
  transaction_id : Int // Transaction ID
  text : String // Command text to complete
}

///|
pub impl @mc.Packet for CommandSuggestionsRequestC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for CommandSuggestionsRequestC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_string(buf, self.text)
}

///|
pub impl @mc.Packet for CommandSuggestionsRequestC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let transaction_id = @types.read_varint(buf)
  let text = @types.read_string(buf)
  { transaction_id, text }
}
