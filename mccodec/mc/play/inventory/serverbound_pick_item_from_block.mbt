///|
/// Pick Item From Block packet (0x23)
/// Picks item from block (middle click)
struct PickItemFromBlockC2S {
  location : @types.Position // Block position
  include_nbt : Bool // Include NBT data
}

///|
impl @mc.Packet for PickItemFromBlockC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PickItemFromBlockC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_position(buf, self.location)
  @types.write_bool(buf, self.include_nbt)
}

///|
impl @mc.Packet for PickItemFromBlockC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let location = @types.read_position(buf)
  let include_nbt = @types.read_bool(buf)
  { location, include_nbt }
}

