///|
/// Bundle Item Selected packet (0x02)  
/// Selects item from bundle
pub(all) struct BundleItemSelectedC2S {
  slot_id : Int // Slot containing bundle
  selected_item_index : Int // Index of selected item
}

///|
pub impl @mc.Packet for BundleItemSelectedC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for BundleItemSelectedC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.slot_id)
  @types.write_varint(buf, self.selected_item_index)
}

///|
pub impl @mc.Packet for BundleItemSelectedC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let slot_id = @types.read_varint(buf)
  let selected_item_index = @types.read_varint(buf)
  { slot_id, selected_item_index }
}

