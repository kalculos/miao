///|
/// Explosion packet (0x20)
/// Creates explosion effect
struct ExplosionS2C {
  x : Double // Explosion X
  y : Double // Explosion Y
  z : Double // Explosion Z
  strength : Float // Explosion strength
  records : Array[(Int, Int, Int)] // Affected block positions
  player_motion_x : Float // Player knockback X
  player_motion_y : Float // Player knockback Y
  player_motion_z : Float // Player knockback Z
  block_interaction : Int // Block interaction type
  small_explosion_particle : String // Small particle data
  large_explosion_particle : String // Large particle data
  explosion_sound : String // Explosion sound
}
///|
impl @mc.Packet for ExplosionS2C with clientbound(self) {
  true
}