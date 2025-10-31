///|
/// Test Instance Block Action packet (0x3E)
/// Performs test block action
struct TestInstanceBlockActionC2S {
  location : @types.Position // Block position
  action : Int // Test action type enum(0=init, 1=query, 2=set, 3=reset, 4=save, 5=export, 6=run)
  test_id: @types.Identifier // Test identifier
  size_x : Int // Test size X
  size_y : Int // Test size Y
  size_z : Int // Test size Z
  rotation: Int // Test rotation enum(0=none, 1=clockwise_90, 2=clockwise_180, 3=counterclockwise_90)
  ignore_entities : Bool // Ignore entities flag
  status: Int // enum(0=cleared, 1=running, 2=finished)
  error_message : String? // Error message
}

///|
impl @mc.Packet for TestInstanceBlockActionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for TestInstanceBlockActionC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  // Position as 3 separate ints
  @types.write_position(buf, self.location)
  @types.write_varint(buf, self.action)
  @types.write_identifier(buf, self.test_id)
  @types.write_varint(buf, self.size_x)
  @types.write_varint(buf, self.size_y)
  @types.write_varint(buf, self.size_z)
  @types.write_varint(buf, self.rotation)
  @types.write_bool(buf, self.ignore_entities)
  @types.write_varint(buf, self.status)
  @types.write_optional(buf, self.error_message, @types.write_string)
}

///|
impl @mc.Packet for TestInstanceBlockActionC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let location = @types.read_position(buf)
  let action = @types.read_varint(buf)
  let test_id = @types.read_identifier(buf)
  let size_x = @types.read_varint(buf)
  let size_y = @types.read_varint(buf)
  let size_z = @types.read_varint(buf)
  let rotation = @types.read_varint(buf)
  let ignore_entities = @types.read_bool(buf)
  let status = @types.read_varint(buf)
  let error_message = @types.read_optional(buf, @types.read_string)
  { location, action, test_id, size_x, size_y, size_z, rotation, ignore_entities, status, error_message }
}

