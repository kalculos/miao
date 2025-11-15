///|
/// Pick Item From Block packet (0x23)
/// Picks item from block (middle click)
pub(all) struct PickItemFromBlockC2S {
  location : @types.Position // Block position
  include_nbt : Bool // Include NBT data
}

///|
pub impl @mc.Packet for PickItemFromBlockC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PickItemFromBlockC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_position(buf, self.location)
  @types.write_bool(buf, self.include_nbt)
}

///|
pub impl @mc.Packet for PickItemFromBlockC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let location = @types.read_position(buf)
  let include_nbt = @types.read_bool(buf)
  { location, include_nbt }
}
