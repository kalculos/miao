///|
/// Chat Command packet (0x06)
/// Sends chat command
pub(all) struct ChatCommandC2S {
  command : String // Command text (without /)
}

///|
pub impl @mc.Packet for ChatCommandC2S with clientbound(_) {
  false
}

pub impl @mc.Packet for ChatCommandC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.command)
}

pub impl @mc.Packet for ChatCommandC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let command = @types.read_string(buf)
  { command, }

}

