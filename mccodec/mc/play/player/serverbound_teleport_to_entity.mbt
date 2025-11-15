///|
/// Teleport To Entity packet (0x3D)
/// Teleports to entity (spectator mode)
pub(all) struct TeleportToEntityC2S {
  target_player : @uuid.UUID // Target player UUID
}

///|
pub impl @mc.Packet for TeleportToEntityC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for TeleportToEntityC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_uuid(buf, self.target_player)
}

///|
pub impl @mc.Packet for TeleportToEntityC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { target_player: @types.read_uuid(buf) }
}
