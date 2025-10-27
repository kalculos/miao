///|
/// Query Block Entity Tag packet (0x01)
/// Queries block entity NBT data
struct QueryBlockEntityTagC2S {
  transaction_id : Int // Transaction ID
  location : @types.Position // Block position
}

///|
impl @mc.Packet for QueryBlockEntityTagC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for QueryBlockEntityTagC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_position(buf, self.location)
}

///|
impl @mc.Packet for QueryBlockEntityTagC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let transaction_id = @types.read_varint(buf)
  let location = @types.read_position(buf)
  { transaction_id, location }
}

