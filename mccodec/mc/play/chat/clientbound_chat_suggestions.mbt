///|
/// Chat Suggestions packet (0x17)
/// Provides chat suggestions
pub(all) struct ChatSuggestionsS2C {
  action : Int // Action enum(0=add, 1=remove, 2=set)
  entries : FixedArray[String] // Chat suggestion entries
}

///|
pub impl @mc.Packet for ChatSuggestionsS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ChatSuggestionsS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.action)
  @types.write_prefix_array(buf, self.entries, @types.write_string)
}

///|
pub impl @mc.Packet for ChatSuggestionsS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let action = @types.read_varint(buf)
  let entries = @types.read_prefix_array(buf, @types.read_string)
  { action, entries }
}
