///|
/// Login Success packet (0x02)
/// Sent when login is successful, switches to configuration state
pub(all) struct LoginSuccessS2C {
  profile : @types.GameProfile // Game Profile (contains UUID and username)
}

///|
pub impl @mc.Packet for LoginSuccessS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for LoginSuccessS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_game_profile(buf, self.profile)
}

///|
pub impl @mc.Packet for LoginSuccessS2C with deserialize(buf : &@buffer.Buffer) {
  let profile = @types.read_game_profile(buf)
  { profile, }
}
