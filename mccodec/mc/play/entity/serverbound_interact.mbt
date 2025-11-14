///|
/// Interact packet (0x19)
/// Interacts with entity
pub(all) struct InteractC2S {
  entity_id : Int // Target entity ID
  interaction_type : Int // Interaction type enum(0=interact, 1=attack, 2=interact_at)
  target_x : Float? // Target X (for at interaction)
  target_y : Float? // Target Y (for at interaction) 
  target_z : Float? // Target Z (for at interaction)
  hand : Int? // Hand used (for interact/interact_at) enum(0=main, 1=off)
  sneaking : Bool // Whether player is sneaking
}

///|
pub impl @mc.Packet for InteractC2S with clientbound(_) {
  false
}

pub impl @mc.Packet for InteractC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.entity_id)
  @types.write_varint(buf, self.interaction_type)
  if self.interaction_type == 2 {
    buf.write_float(self.target_x.unwrap())
    buf.write_float(self.target_y.unwrap())
    buf.write_float(self.target_z.unwrap())
  }
  if self.interaction_type == 0 || self.interaction_type == 2 {
    @types.write_varint(buf, self.hand.unwrap())
  }
  @types.write_bool(buf, self.sneaking)
}

pub impl @mc.Packet for InteractC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let entity_id = @types.read_varint(buf)
  let interaction_type = @types.read_varint(buf)
  let (target_x, target_y, target_z) = if interaction_type == 2 {
    (
      Some(buf.read_float()),
      Some(buf.read_float()),
      Some(buf.read_float()),
    )
  } else {
    (None, None, None)
  }
  let hand = if interaction_type == 0 || interaction_type == 2 {
    Some(@types.read_varint(buf))
  } else {
    None
  }
  let sneaking = @types.read_bool(buf)
  {
    entity_id,
    interaction_type,
    target_x,
    target_y,
    target_z,
    hand,
    sneaking,
  }
}

