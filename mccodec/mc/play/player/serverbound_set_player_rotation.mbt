///|
/// Set Player Rotation packet (0x1F)
/// Updates player look direction
pub(all) struct SetPlayerRotationC2S {
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  on_ground : Byte // Whether on ground, (0x01=on ground, 0x02=pushing against wall)
}

///|
pub impl @mc.Packet for SetPlayerRotationC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for SetPlayerRotationC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_float(self.yaw)
  buf.write_float(self.pitch)
  buf.write_byte(self.on_ground)
}

///|
pub impl @mc.Packet for SetPlayerRotationC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let yaw = buf.read_float()
  let pitch = buf.read_float()
  let on_ground = buf.read_byte()
  { yaw, pitch, on_ground }
}
