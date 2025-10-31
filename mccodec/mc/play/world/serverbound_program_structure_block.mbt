///|
/// Program Structure Block packet (0x39)
/// Programs structure block
struct ProgramStructureBlockC2S {
  location : @types.Position // Structure block position
  action : Int // Action type, TODO: enum
  mode : Int // Structure mode, TODO: enum
  name : String // Structure name
  offset_x : Byte // X offset
  offset_y : Byte // Y offset
  offset_z : Byte // Z offset
  size_x : Byte // X size
  size_y : Byte // Y size
  size_z : Byte // Z size
  mirror : Int // Mirror type, TODO: enum
  rotation : Int // Rotation type, TODO: enum
  metadata : String // Metadata
  integrity : Float // Structure integrity
  seed : Int64 // Structure seed
  flags : Byte // Structure flags
}

///|
impl @mc.Packet for ProgramStructureBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ProgramStructureBlockC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.action)
  @types.write_varint(buf, self.mode)
  @types.write_string(buf, self.name)
  buf.write_byte(self.offset_x)
  buf.write_byte(self.offset_y)
  buf.write_byte(self.offset_z)
  buf.write_byte(self.size_x)
  buf.write_byte(self.size_y)
  buf.write_byte(self.size_z)
  @types.write_varint(buf, self.mirror)
  @types.write_varint(buf, self.rotation)
  @types.write_string(buf, self.metadata)
  buf.write_float(self.integrity)
  @types.write_varlong(buf, self.seed)
  buf.write_byte(self.flags)
}

///|
impl @mc.Packet for ProgramStructureBlockC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let location = @types.read_position(buf)
  let action = @types.read_varint(buf)
  let mode = @types.read_varint(buf)
  let name = @types.read_string(buf)
  let offset_x = buf.read_byte()
  let offset_y = buf.read_byte()
  let offset_z = buf.read_byte()
  let size_x = buf.read_byte()
  let size_y = buf.read_byte()
  let size_z = buf.read_byte()
  let mirror = @types.read_varint(buf)
  let rotation = @types.read_varint(buf)
  let metadata = @types.read_string(buf)
  let integrity = buf.read_float()
  let seed = @types.read_varlong(buf)
  let flags = buf.read_byte();
  { location, action, mode, name, offset_x, offset_y, offset_z, size_x, size_y, size_z, mirror, rotation, metadata, integrity, seed, flags }
}

