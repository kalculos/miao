///|
/// Set Test Block packet (0x3A)
/// Sets test block data (for test frameworks)
struct SetTestBlockC2S {
  location : @types.Position // Block position
  block_type : Int // Block type, enum
  message : String // Block NBT data
}

///|
impl @mc.Packet for SetTestBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetTestBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.block_type)
  @types.write_string(buf, self.message)
}

///|
impl @mc.Packet for SetTestBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let block_type = @types.read_varint(buf)
  let message = @types.read_string(buf)
  { location, block_type, message }
}

