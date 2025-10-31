///|
/// Chat Suggestions packet (0x17)
/// Provides chat suggestions
struct ChatSuggestionsS2C {
  action : Int // Action enum(0=add, 1=remove, 2=set)
  entries : FixedArray[String] // Chat suggestion entries
}

///|
impl @mc.Packet for ChatSuggestionsS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ChatSuggestionsS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.action)
  @types.write_prefix_array(buf, self.entries, @types.write_string)
}

///|
impl @mc.Packet for ChatSuggestionsS2C with deserialize(buf : &@bytebuf.ByteBuf) {
  let action = @types.read_varint(buf)
  let entries = @types.read_prefix_array(buf, @types.read_string)
  { action, entries }
}
