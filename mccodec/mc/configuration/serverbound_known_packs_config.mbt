///|
/// Serverbound Known Packs packet (0x07)
/// Informs server of which data packs client has
struct ServerboundKnownPacksC2S {
  known_packs : FixedArray[(String, String, String)] // (Namespace, ID, Version) tuples
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_prefix_array(buf, self.known_packs, (b, pack) => {
    @types.write_string(b, pack.0)
    @types.write_string(b, pack.1)
    @types.write_string(b, pack.2)
  })
}

///|
impl @mc.Packet for ServerboundKnownPacksC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let known_packs = @types.read_prefix_array(buf, b => {
    let ns = @types.read_string(b)
    let id = @types.read_string(b)
    let version = @types.read_string(b)
    (ns, id, version)
  })
  { known_packs, }
}

