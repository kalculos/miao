///|
/// Update Entity Position packet (0x2E)
/// Updates entity position
pub(all) struct UpdateEntityPositionS2C {
  entity_id : Int // Entity ID
  delta_x : Int16 // X movement delta
  delta_y : Int16 // Y movement delta
  delta_z : Int16 // Z movement delta
  on_ground : Bool // On ground flag
}
///|
pub impl @mc.Packet for UpdateEntityPositionS2C with clientbound(_) {
  true
}