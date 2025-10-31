///|
/// Program Command Block packet (0x35)
/// Programs command block
struct ProgramCommandBlockC2S {
  location : @types.Position // Command block position
  command : String // Command text
  mode : Int // Command block mode enum(0=chain, 1=repeat, 2=impulse)
  flags : Byte // Command block flags
}

///|
impl @mc.Packet for ProgramCommandBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramCommandBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_string(buf, self.command)
  @types.write_varint(buf, self.mode)
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for ProgramCommandBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let command = @types.read_string(buf)
  let mode = @types.read_varint(buf)
  let flags = buf.read_byte() |> Option::unwrap
  { location, command, mode, flags }
}

