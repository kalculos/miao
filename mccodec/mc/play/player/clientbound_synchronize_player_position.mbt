///|
/// Synchronize Player Position packet (0x41)
/// Synchronizes player position
struct SynchronizePlayerPositionS2C {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
  flags : Byte // Relative position flags
  teleport_id : Int // Teleport ID
}
///|
impl @mc.Packet for SynchronizePlayerPositionS2C with clientbound(self) {
  true
}