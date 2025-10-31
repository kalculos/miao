///|
/// System Chat Message packet (0x72)
/// System chat message
struct SystemChatMessageS2C {
  content : String // Message content, TODO: Text Component
  overlay : Bool // Display as overlay
}

///|
impl @mc.Packet for SystemChatMessageS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for SystemChatMessageS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.content)
  @types.write_bool(buf, self.overlay)
}

///|
impl @mc.Packet for SystemChatMessageS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let content = @types.read_string(buf)
  let overlay = @types.read_bool(buf)
  { content, overlay }
}
