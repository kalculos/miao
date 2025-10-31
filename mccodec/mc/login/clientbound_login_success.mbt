///|
/// Login Success packet (0x02)
/// Sent when login is successful, switches to configuration state
struct LoginSuccessS2C {
  profile : @types.GameProfile // Game Profile (contains UUID and username)
}

///|
impl @mc.Packet for LoginSuccessS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for LoginSuccessS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_game_profile(buf, self.profile)
}

///|
impl @mc.Packet for LoginSuccessS2C with deserialize(buf : &@buffer.Buffer) {
  let profile = @types.read_game_profile(buf)
  { profile, }
}
