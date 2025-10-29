///|
/// TODO: Definition of entries
/// Registry Data packet (0x07)
/// Represents registries sent from server to client
struct RegistryDataS2C {
  registry_id : @types.Identifier // Registry identifier
  entries : FixedArray[(String, String)] // Entry ID and NBT data pairs
}

///|
impl @mc.Packet for RegistryDataS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for RegistryDataS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_identifier(buf, self.registry_id)
  @types.write_prefix_array(buf, self.entries, (b, entry) => {
    @types.write_string(b, entry.0)
    @types.write_string(b, entry.1)
  })
}

///|
impl @mc.Packet for RegistryDataS2C with deserialize(buf : &@bytebuf.ByteBuf) {
  let registry_id = @types.read_identifier(buf)
  let entries = @types.read_prefix_array(buf, b => {
    let entry_id = @types.read_string(b)
    let nbt_data = @types.read_string(b)
    (entry_id, nbt_data)
  })
  { registry_id, entries }
}
