///|
/// Open Horse Screen packet (0x23)
/// Opens horse inventory
struct OpenHorseScreenS2C {
  window_id : Int // Window ID
  slot_count : Int // Number of slots
  entity_id : Int // Horse entity ID
}

///|
impl @mc.Packet for OpenHorseScreenS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for OpenHorseScreenS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.window_id)
  @types.write_varint(buf, self.slot_count)
  buf.write_int(self.entity_id)
}

///|
impl @mc.Packet for OpenHorseScreenS2C with deserialize(buf : &@buffer.Buffer) {
  let window_id = @types.read_varint(buf)
  let slot_count = @types.read_varint(buf)
  let entity_id = buf.read_int()
  { window_id, slot_count, entity_id }
}
