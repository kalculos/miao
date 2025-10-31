///|
/// Remove Resource Pack (configuration) packet (0x08)
/// Removes a resource pack from client
struct RemoveResourcePackConfigS2C {
  uuid : @uuid.UUID? // UUID of resource pack to remove (if None, removes all)
}

///|
impl @mc.Packet for RemoveResourcePackConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for RemoveResourcePackConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_optional(buf, self.uuid, @types.write_uuid)
}

///|
impl @mc.Packet for RemoveResourcePackConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  { uuid: @types.read_optional(buf, @types.read_uuid) }
}

