///|
/// Tag Query Response packet (0x74)
/// Response to tag query
struct TagQueryResponseS2C {
  transaction_id : Int // Transaction ID
  nbt : @nbt.NBTTag // NBT data
}

///|
impl @mc.Packet for TagQueryResponseS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for TagQueryResponseS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.transaction_id)
  @types.write_nbt(buf, self.nbt)
}

///|
impl @mc.Packet for TagQueryResponseS2C with deserialize(buf : &@buffer.Buffer) {
  let transaction_id = @types.read_varint(buf)
  let nbt = @types.read_nbt(buf)
  { transaction_id, nbt }
}
