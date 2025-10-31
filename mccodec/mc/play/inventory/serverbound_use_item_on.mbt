///|
/// Use Item On packet (0x3F)
/// Uses item on block
struct UseItemOnC2S {
  hand : Int // Hand used enum(0=main, 1=off)
  location : @types.Position // Block position
  direction : Int // Block face, TODO: enum
  cursor_position_x : Float // Cursor X on block
  cursor_position_y : Float // Cursor Y on block  
  cursor_position_z : Float // Cursor Z on block
  inside_block : Bool // Inside block check
  world_border_hit: Bool // Whether world border was hit
  sequence : Int // Action sequence
}

///|
impl @mc.Packet for UseItemOnC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for UseItemOnC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.hand)
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.direction)
  buf.write_float(self.cursor_position_x)
  buf.write_float(self.cursor_position_y)
  buf.write_float(self.cursor_position_z)
  @types.write_bool(buf, self.inside_block)
  @types.write_bool(buf, self.world_border_hit)
  @types.write_varint(buf, self.sequence)
}

///|
impl @mc.Packet for UseItemOnC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let hand = @types.read_varint(buf)
  let location = @types.read_position(buf)
  let direction = @types.read_varint(buf)
  let cursor_position_x = buf.read_float()
  let cursor_position_y = buf.read_float()
  let cursor_position_z = buf.read_float()
  let inside_block = @types.read_bool(buf)
  let world_border_hit = @types.read_bool(buf)
  let sequence = @types.read_varint(buf)
  { hand, location, direction, cursor_position_x, cursor_position_y, cursor_position_z, inside_block, world_border_hit, sequence }
}

