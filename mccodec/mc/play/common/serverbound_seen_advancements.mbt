///|
/// Seen Advancements packet (0x31)
/// Updates seen advancement tabs
struct SeenAdvancementsC2S {
  action : Int // Action (0=opened_tab, 1=closed_screen)
  tab_id : @types.Identifier? // Tab identifier (for opened_tab)
}

///|
impl @mc.Packet for SeenAdvancementsC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SeenAdvancementsC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.action)
  @types.write_optional(buf, self.tab_id, @types.write_identifier)
}

///|
impl @mc.Packet for SeenAdvancementsC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let action = @types.read_varint(buf)
  let tab_id = @types.read_optional(buf, @types.read_identifier)
  { action, tab_id }
}

