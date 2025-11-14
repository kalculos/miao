///|
/// Move Vehicle (clientbound) packet (0x32)
/// Moves vehicle entity
pub(all) struct MoveVehicleS2C {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}
///|
pub impl @mc.Packet for MoveVehicleS2C with clientbound(_) {
  true
}