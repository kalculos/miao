///|
/// Set Cooldown packet (0x16)
/// Sets item cooldown
struct SetCooldownS2C {
  cooldown_group : @types.Identifier // Identifier of the item or the cooldown group
  cooldown_ticks : Int // Number of ticks to apply a cooldown for, or 0 to clear the cooldown. 
}

///|
impl @mc.Packet for SetCooldownS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for SetCooldownS2C with serialize(self, buf : &@buffer.Buffer) {
  @types.write_identifier(buf, self.cooldown_group)
  @types.write_varint(buf, self.cooldown_ticks)
}

///|
impl @mc.Packet for SetCooldownS2C with deserialize(buf : &@buffer.Buffer) {
  let cooldown_group = @types.read_identifier(buf)
  let cooldown_ticks = @types.read_varint(buf)
  { cooldown_group, cooldown_ticks }
}
