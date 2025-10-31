///|
/// Command Suggestions Request packet (0x0E)
/// Requests tab completion
struct CommandSuggestionsRequestC2S {
  transaction_id : Int // Transaction ID
  text : String // Command text to complete
}

///|
impl @mc.Packet for CommandSuggestionsRequestC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CommandSuggestionsRequestC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_string(buf, self.text)
}

///|
impl @mc.Packet for CommandSuggestionsRequestC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let transaction_id = @types.read_varint(buf)
  let text = @types.read_string(buf)
  { transaction_id, text }
}

