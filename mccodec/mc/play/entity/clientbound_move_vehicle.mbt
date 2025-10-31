///|
/// Move Vehicle (clientbound) packet (0x32)
/// Moves vehicle entity
struct MoveVehicleS2C {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}
///|
impl @mc.Packet for MoveVehicleS2C with clientbound(self) {
  true
}