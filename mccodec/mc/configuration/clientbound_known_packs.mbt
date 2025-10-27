///|
/// Clientbound Known Packs packet (0x0E)
/// Informs client of which data packs are present
struct ClientboundKnownPacksS2C {
  known_packs : FixedArray[(String, String, String)] // (Namespace, ID, Version) tuples, prehaps we should add a type for Known Pack
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
  @types.write_prefix_array(buf, self.known_packs, (b, pack) => {
    @types.write_string(b, pack.0)
    @types.write_string(b, pack.1)
    @types.write_string(b, pack.2)
  })
}

///|
impl @mc.Packet for ClientboundKnownPacksS2C with deserialize(
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
