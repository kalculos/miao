///|
/// Program Command Block Minecart packet (0x36)
/// Programs command block minecart
struct ProgramCommandBlockMinecartC2S {
  entity_id : Int // Minecart entity ID
  command : String // Command text
  track_output : Bool // Track output
}

///|
impl @mc.Packet for ProgramCommandBlockMinecartC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramCommandBlockMinecartC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_string(buf, self.command)
  @types.write_bool(buf, self.track_output)
}

///|
impl @mc.Packet for ProgramCommandBlockMinecartC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let entity_id = @types.read_varint(buf)
  let command = @types.read_string(buf)
  let track_output = @types.read_bool(buf)
  { entity_id, command, track_output }
}

