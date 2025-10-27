///|
/// Set Test Block packet (0x3A)
/// Sets test block data (for test frameworks)
struct SetTestBlockC2S {
  location : @types.Position // Block position
  block_type : Int // Block type
  block_data : String // Block NBT data
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
  @types.write_string(buf, self.block_data)
}

///|
impl @mc.Packet for SetTestBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let block_type = @types.read_varint(buf)
  let block_data = @types.read_string(buf)
  { location, block_type, block_data }
}

