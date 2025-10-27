///|
/// Program Jigsaw Block packet (0x38)
/// Programs jigsaw block
struct ProgramJigsawBlockC2S {
  location : @types.Position // Jigsaw position
  name : String // Jigsaw name, TODO: Identifier type
  target : String // Target name, TODO: Identifier type
  pool : String // Template pool, TODO: Identifier type
  final_state : String // Final state
  joint_type : String // Joint type
  selection_priority : Int // Selection priority
  placement_priority : Int // Placement priority
}

///|
impl @mc.Packet for ProgramJigsawBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramJigsawBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_string(buf, self.name)
  @types.write_string(buf, self.target)
  @types.write_string(buf, self.pool)
  @types.write_string(buf, self.final_state)
  @types.write_string(buf, self.joint_type)
  @types.write_varint(buf, self.selection_priority)
  @types.write_varint(buf, self.placement_priority)
}

///|
impl @mc.Packet for ProgramJigsawBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let name = @types.read_string(buf)
  let target = @types.read_string(buf)
  let pool = @types.read_string(buf)
  let final_state = @types.read_string(buf)
  let joint_type = @types.read_string(buf)
  let selection_priority = @types.read_varint(buf)
  let placement_priority = @types.read_varint(buf)
  { location, name, target, pool, final_state, joint_type, selection_priority, placement_priority }
}

