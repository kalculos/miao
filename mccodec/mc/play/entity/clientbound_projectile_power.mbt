///|
/// Projectile Power packet (0x80)
/// Sets projectile power data
struct ProjectilePowerS2C {
  entity_id : Int // Projectile entity ID
  power_x : Double // Power X
  power_y : Double // Power Y
  power_z : Double // Power Z
}
///|
impl @mc.Packet for ProjectilePowerS2C with clientbound(self) {
  true
}