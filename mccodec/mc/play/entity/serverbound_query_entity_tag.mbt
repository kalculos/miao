///|
/// Query Entity Tag packet (0x18)
/// Queries entity NBT data
pub(all) struct QueryEntityTagC2S {
  transaction_id : Int // Transaction ID
  entity_id : Int // Entity ID
}

///|
pub impl @mc.Packet for QueryEntityTagC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for QueryEntityTagC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_varint(buf, self.entity_id)
}

///|
pub impl @mc.Packet for QueryEntityTagC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let transaction_id = @types.read_varint(buf)
  let entity_id = @types.read_varint(buf)
  { transaction_id, entity_id }
}

