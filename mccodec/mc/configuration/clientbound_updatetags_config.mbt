///|
/// Update Tags (configuration) packet (0x0D)
/// Updates tags on client
struct UpdateTagsConfigS2C {
  // Registry -> (Tag name -> Entry IDs)
  tags : Map[@types.Identifier, Map[@types.Identifier, FixedArray[Int]]]
}

///|
impl @mc.Packet for UpdateTagsConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for UpdateTagsConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_map(buf, self.tags, @types.write_identifier, (buf, tag_map) => @types.write_map(
    buf,
    tag_map,
    @types.write_identifier,
    (buf, entry_ids) => @types.write_prefix_array(
      buf, entry_ids, @types.write_varint,
    ),
  ))
}

///|
impl @mc.Packet for UpdateTagsConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let tags = @types.read_map(buf, @types.read_identifier, buf => @types.read_map(
    buf,
    @types.read_identifier,
    buf => @types.read_prefix_array(buf, @types.read_varint),
  ))
  { tags, }
}
