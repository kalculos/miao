///|
/// Clientbound Known Packs packet (0x0E)
/// Informs client of which data packs are present
struct ClientboundKnownPacksS2C {
  known_packs : FixedArray[@types.KnownPack] // (Namespace, ID, Version) tuples, prehaps we should add a type for Known Pack
}

///|
impl @mc.Packet for ClientboundKnownPacksS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for ClientboundKnownPacksS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_prefix_array(buf, self.known_packs, @types.write_known_pack)
}

///|
impl @mc.Packet for ClientboundKnownPacksS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let known_packs = @types.read_prefix_array(buf, @types.read_known_pack)
  { known_packs, }
}
