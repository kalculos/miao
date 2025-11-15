///|
/// Player Command packet (0x29)
/// Player entity command
pub(all) struct PlayerCommandC2S {
  entity_id : Int // Entity ID
  action_id : Int // Action enum(0=crouch, 1=uncrouch, 2=leave_bed, 3=start_sprinting, 4=stop_sprinting, 5=start_horse_jump, 6=stop_horse_jump, 7=open_vehicle_inventory, 8=start_flying_elytra)
  jump_boost : Int // Jump boost (for horse jumping)
}

///|
pub impl @mc.Packet for PlayerCommandC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for PlayerCommandC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_varint(buf, self.action_id)
  @types.write_varint(buf, self.jump_boost)
}

///|
pub impl @mc.Packet for PlayerCommandC2S with deserialize(buf : &@buffer.Buffer) {
  let entity_id = @types.read_varint(buf)
  let action_id = @types.read_varint(buf)
  let jump_boost = @types.read_varint(buf)
  { entity_id, action_id, jump_boost }
}
