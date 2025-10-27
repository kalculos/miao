///|
/// Confirm Teleportation packet (0x00)
/// Confirms server teleportation
struct ConfirmTeleportationC2S {
  teleport_id : Int // Teleport ID from server
}

///|
impl @mc.Packet for ConfirmTeleportationC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ConfirmTeleportationC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.teleport_id)
}

///|
impl @mc.Packet for ConfirmTeleportationC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { teleport_id: @types.read_varint(buf) }
}

