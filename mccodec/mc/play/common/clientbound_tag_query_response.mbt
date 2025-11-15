///|
/// Tag Query Response packet (0x74)
/// Response to tag query
pub(all) struct TagQueryResponseS2C {
  transaction_id : Int // Transaction ID
  nbt : @nbt.NBTTag // NBT data
}

///|
pub impl @mc.Packet for TagQueryResponseS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for TagQueryResponseS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_nbt(buf, self.nbt)
}

///|
pub impl @mc.Packet for TagQueryResponseS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let transaction_id = @types.read_varint(buf)
  let nbt = @types.read_nbt(buf)
  { transaction_id, nbt }
}
