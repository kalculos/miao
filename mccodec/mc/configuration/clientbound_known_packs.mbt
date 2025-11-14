///|
/// Clientbound Known Packs packet (0x0E)
/// Informs client of which data packs are present
pub(all) struct ClientboundKnownPacksS2C {
  known_packs : FixedArray[@types.KnownPack] // (Namespace, ID, Version) tuples, prehaps we should add a type for Known Pack
}

///|
pub impl @mc.Packet for ClientboundKnownPacksS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for ClientboundKnownPacksS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_prefix_array(buf, self.known_packs, @types.write_known_pack)
}

///|
pub impl @mc.Packet for ClientboundKnownPacksS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let known_packs = @types.read_prefix_array(buf, @types.read_known_pack)
  { known_packs, }
}
