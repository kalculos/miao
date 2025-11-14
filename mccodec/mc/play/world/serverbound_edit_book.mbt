///|
/// Edit Book packet (0x17)
/// Edits book content
pub(all) struct EditBookC2S {
  slot : Int // Slot containing book
  entries : FixedArray[String] // Book page contents
  title : String? // Book title (if signing)
}

///|
pub impl @mc.Packet for EditBookC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for EditBookC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.slot)
  @types.write_prefix_array(buf, self.entries, @types.write_string)
  @types.write_optional(buf, self.title, @types.write_string)
}

///|
pub impl @mc.Packet for EditBookC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let slot = @types.read_varint(buf)
  let entries = @types.read_prefix_array(buf, @types.read_string)
  let title = @types.read_optional(buf, @types.read_string)
  { slot, entries, title }
}

