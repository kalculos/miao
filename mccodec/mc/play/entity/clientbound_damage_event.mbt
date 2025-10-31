///|
/// Damage Event packet (0x19)
/// Shows damage animation
struct DamageEventS2C {
  entity_id : Int // Damaged entity
  source_type_id : Int // Damage source type
  source_cause_id : Int // Entity causing damage (or 0)
  source_direct_id : Int // Direct damage source (or 0)  
  source_position : (Double, Double, Double)? // Damage source position
}
///|
impl @mc.Packet for DamageEventS2C with clientbound(self) {
  true
}