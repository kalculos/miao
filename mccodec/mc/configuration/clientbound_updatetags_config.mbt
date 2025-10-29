///|
/// Update Tags (configuration) packet (0x0D)
/// Updates tags on client
struct UpdateTagsConfigS2C {
  // Registry -> (Tag name -> Entry IDs), prehaps we should add a type for tag
  tags : FixedArray[(@types.Identifier, FixedArray[(@types.Identifier, FixedArray[Int])])]
}

///|
impl @mc.Packet for UpdateTagsConfigS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for UpdateTagsConfigS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_prefix_array(buf, self.tags, (b, t) => {
    @types.write_identifier(b, t.0)
    @types.write_prefix_array(b, t.1, (by, ta) => {
      @types.write_identifier(by, ta.0)
      @types.write_prefix_array(by, ta.1, @types.write_varint)
    })
  })
}

///|
impl @mc.Packet for UpdateTagsConfigS2C with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let tags = @types.read_prefix_array(buf, b => {
    let registry_name = @types.read_identifier(b)
    let tag_entries = @types.read_prefix_array(b, tb => {
      let tag_name = @types.read_identifier(tb)
      let ids = @types.read_prefix_array(tb, @types.read_varint)
      (tag_name, ids)
    })
    (registry_name, tag_entries)
  })
  { tags, }
}

