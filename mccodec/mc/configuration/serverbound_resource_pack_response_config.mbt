///|
/// Resource Pack Response (configuration) packet (0x06)
/// Client's response to resource pack requests
pub(all) struct ResourcePackResponseConfigC2S {
  uuid : @uuid.UUID // UUID of the resource pack
  result : Int // Result ID (0-7, see protocol docs), TODO: enum
}

///|
pub impl @mc.Packet for ResourcePackResponseConfigC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ResourcePackResponseConfigC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_uuid(buf, self.uuid)
  @types.write_varint(buf, self.result)
}

///|
pub impl @mc.Packet for ResourcePackResponseConfigC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let uuid = @types.read_uuid(buf)
  let result = @types.read_varint(buf)
  { uuid, result }
}

