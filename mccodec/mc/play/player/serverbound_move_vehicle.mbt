///|
/// Move Vehicle (serverbound) packet (0x21)
/// Moves vehicle entity
struct MoveVehicleC2S {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  on_ground: Bool // Whether on ground (This value does not seem to exist)
}

///|
impl @mc.Packet for MoveVehicleC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for MoveVehicleC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_double(self.x)
  buf.write_double(self.y)
  buf.write_double(self.z)
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
  @types.write_bool(buf, self.on_ground)
}

///|
impl @mc.Packet for MoveVehicleC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let x = buf.read_double().unwrap()
  let y = buf.read_double().unwrap()
  let z = buf.read_double().unwrap()
  let yaw = buf.read_float().unwrap()
  let pitch = buf.read_float().unwrap()
  let on_ground = @types.read_bool(buf)
  { x, y, z, yaw, pitch, on_ground }
}

