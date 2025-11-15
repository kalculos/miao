///|
/// Set Player Position and Rotation packet (0x1E)
/// Updates player position and look direction
pub(all) struct SetPlayerPositionAndRotationC2S {
  x : Double // X position
  feet_y : Double // Y position at feet
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
pub impl @mc.Packet for SetPlayerPositionAndRotationC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for SetPlayerPositionAndRotationC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_double(self.x)
  buf.write_double(self.feet_y)
  buf.write_double(self.z)
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
  buf.write_byte(self.on_ground)
}

///|
pub impl @mc.Packet for SetPlayerPositionAndRotationC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let x = buf.read_double()
  let feet_y = buf.read_double()
  let z = buf.read_double()
  let yaw = buf.read_float()
  let pitch = buf.read_float()
  let on_ground = buf.read_byte()
  { x, feet_y, z, yaw, pitch, on_ground }
}
