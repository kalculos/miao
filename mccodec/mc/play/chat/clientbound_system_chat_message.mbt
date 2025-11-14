///|
/// System Chat Message packet (0x72)
/// System chat message
pub(all) struct SystemChatMessageS2C {
  content : String // Message content, TODO: Text Component
  overlay : Bool // Display as overlay
}

///|
pub impl @mc.Packet for SystemChatMessageS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for SystemChatMessageS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.content)
  @types.write_bool(buf, self.overlay)
}

///|
pub impl @mc.Packet for SystemChatMessageS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let content = @types.read_string(buf)
  let overlay = @types.read_bool(buf)
  { content, overlay }
}
