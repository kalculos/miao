///|
/// Set Player Position packet (0x1D)
/// Updates player position
struct SetPlayerPositionC2S {
  x : Double // X position
  feet_y : Double // Y position at feet
  z : Double // Z position
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
impl @mc.Packet for SetPlayerPositionC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for SetPlayerPositionC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_double(self.x)
  buf.write_double(self.feet_y)
  buf.write_double(self.z)
  buf.write_byte(self.on_ground)
}

///|
impl @mc.Packet for SetPlayerPositionC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let x = buf.read_double().unwrap()
  let feet_y = buf.read_double().unwrap()
  let z = buf.read_double().unwrap()
  let on_ground = buf.read_byte().unwrap()
  { x, feet_y, z, on_ground }
}

