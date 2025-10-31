///|
/// Waypoint packet (0x83)
/// Sets waypoint data
struct WaypointS2C {
  location : (Int, Int, Int) // Waypoint position
  name : String // Waypoint name
  color : Int // Waypoint color
}
///|
impl @mc.Packet for WaypointS2C with clientbound(self) {
  true
}