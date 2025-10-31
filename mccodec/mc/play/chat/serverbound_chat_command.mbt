///|
/// Chat Command packet (0x06)
/// Sends chat command
struct ChatCommandC2S {
  command : String // Command text (without /)
}

///|
impl @mc.Packet for ChatCommandC2S with clientbound(self) {
  false
}

impl @mc.Packet for ChatCommandC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.command)
}

impl @mc.Packet for ChatCommandC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let command = @types.read_string(buf)
  { command, }

}

