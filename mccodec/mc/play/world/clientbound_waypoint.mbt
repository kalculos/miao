///|
/// Waypoint packet (0x83)
/// Sets waypoint data
pub(all) struct WaypointS2C {
  location : (Int, Int, Int) // Waypoint position
  name : String // Waypoint name
  color : Int // Waypoint color
}
///|
pub impl @mc.Packet for WaypointS2C with clientbound(_) {
  true
}