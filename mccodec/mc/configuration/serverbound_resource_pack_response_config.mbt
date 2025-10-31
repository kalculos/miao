///|
/// Resource Pack Response (configuration) packet (0x06)
/// Client's response to resource pack requests
struct ResourcePackResponseConfigC2S {
  uuid : @uuid.UUID // UUID of the resource pack
  result : Int // Result ID (0-7, see protocol docs), TODO: enum
}

///|
impl @mc.Packet for ResourcePackResponseConfigC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ResourcePackResponseConfigC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_uuid(buf, self.uuid)
  @types.write_varint(buf, self.result)
}

///|
impl @mc.Packet for ResourcePackResponseConfigC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let uuid = @types.read_uuid(buf)
  let result = @types.read_varint(buf)
  { uuid, result }
}

