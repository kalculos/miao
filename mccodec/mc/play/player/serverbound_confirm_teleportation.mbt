///|
/// Confirm Teleportation packet (0x00)
/// Confirms server teleportation
pub(all) struct ConfirmTeleportationC2S {
  teleport_id : Int // Teleport ID from server
}

///|
pub impl @mc.Packet for ConfirmTeleportationC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ConfirmTeleportationC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.teleport_id)
}

///|
pub impl @mc.Packet for ConfirmTeleportationC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { teleport_id: @types.read_varint(buf) }
}

