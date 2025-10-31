///|
/// Serverbound Known Packs packet (0x07)
/// Informs server of which data packs client has
struct ServerboundKnownPacksC2S {
  known_packs : FixedArray[@types.KnownPack] // (Namespace, ID, Version) tuples
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_prefix_array(buf, self.known_packs, @types.write_known_pack)
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let known_packs = @types.read_prefix_array(buf, @types.read_known_pack)
  { known_packs, }
}
