///|
/// Teleport To Entity packet (0x3D)
/// Teleports to entity (spectator mode)
struct TeleportToEntityC2S {
  target_player : @uuid.UUID // Target player UUID
}

///|
impl @mc.Packet for TeleportToEntityC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for TeleportToEntityC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_uuid(buf, self.target_player)
}

///|
impl @mc.Packet for TeleportToEntityC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  { target_player: @types.read_uuid(buf) }
}

