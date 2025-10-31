///|
/// Pick Item From Entity packet (0x24)
/// Picks item from entity (middle click)
struct PickItemFromEntityC2S {
  entity_id : Int // Entity ID
  include_nbt : Bool // Include NBT data
}

///|
impl @mc.Packet for PickItemFromEntityC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for PickItemFromEntityC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_bool(buf, self.include_nbt)
}

///|
impl @mc.Packet for PickItemFromEntityC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let entity_id = @types.read_varint(buf)
  let include_nbt = @types.read_bool(buf)
  { entity_id, include_nbt }
}

