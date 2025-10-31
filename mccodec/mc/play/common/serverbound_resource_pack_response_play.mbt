///|
/// Resource Pack Response (play) packet (0x30)
/// Response to resource pack request
struct ResourcePackResponsePlayC2S {
  uuid : @uuid.UUID // Resource pack UUID
  result : Int // Result (0=accepted, 1=declined, 2=failed_download, 3=accepted_download_pack, 4=invalid_url, 5=failed_reload, 6=discarded)
}

///|
impl @mc.Packet for ResourcePackResponsePlayC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ResourcePackResponsePlayC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_uuid(buf, self.uuid)
  @types.write_varint(buf, self.result)
}

///|
impl @mc.Packet for ResourcePackResponsePlayC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let uuid = @types.read_uuid(buf)
  let result = @types.read_varint(buf)
  { uuid, result }
}

