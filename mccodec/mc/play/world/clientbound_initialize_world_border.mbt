///|
/// Initialize World Border packet (0x25)
/// Initializes world border
struct InitializeWorldBorderS2C {
  x : Double // Center X
  z : Double // Center Z
  old_diameter : Double // Current diameter
  new_diameter : Double // New diameter
  speed : Int64 // Resize speed
  portal_teleport_boundary : Int // Portal boundary
  warning_blocks : Int // Warning distance
  warning_time : Int // Warning time
}
///|
impl @mc.Packet for InitializeWorldBorderS2C with clientbound(self) {
  true
}