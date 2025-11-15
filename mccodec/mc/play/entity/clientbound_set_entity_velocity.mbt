///|
/// Set Entity Velocity packet (0x5E)
/// Sets entity velocity
pub(all) struct SetEntityVelocityS2C {
  entity_id : Int // Entity ID
  velocity_x : Int16 // X velocity
  velocity_y : Int16 // Y velocity
  velocity_z : Int16 // Z velocity
}

///|
pub impl @mc.Packet for SetEntityVelocityS2C with clientbound(_) {
  true
}
