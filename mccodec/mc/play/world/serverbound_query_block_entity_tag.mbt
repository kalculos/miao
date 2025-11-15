///|
/// Query Block Entity Tag packet (0x01)
/// Queries block entity NBT data
pub(all) struct QueryBlockEntityTagC2S {
  transaction_id : Int // Transaction ID
  location : @types.Position // Block position
}

///|
pub impl @mc.Packet for QueryBlockEntityTagC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for QueryBlockEntityTagC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_position(buf, self.location)
}

///|
pub impl @mc.Packet for QueryBlockEntityTagC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let transaction_id = @types.read_varint(buf)
  let location = @types.read_position(buf)
  { transaction_id, location }
}
