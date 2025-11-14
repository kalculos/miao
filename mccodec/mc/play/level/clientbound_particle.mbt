///|
/// Particle packet (0x29)
/// Spawns particle effect
pub(all) struct ParticleS2C {
  particle_id : Int // Particle type
  long_distance : Bool // Long distance rendering
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  offset_x : Float // X offset
  offset_y : Float // Y offset
  offset_z : Float // Z offset
  max_speed : Float // Maximum speed
  particle_count : Int // Number of particles
  data : Array[Byte] // Particle-specific data
}
///|
pub impl @mc.Packet for ParticleS2C with clientbound(_) {
  true
}