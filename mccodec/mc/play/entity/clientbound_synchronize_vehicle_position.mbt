///|
/// Synchronize Vehicle Position packet (0x76)
/// Synchronizes vehicle position
pub(all) struct SynchronizeVehiclePositionS2C {
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Float // Yaw angle
  pitch : Float // Pitch angle
}

///|
pub impl @mc.Packet for SynchronizeVehiclePositionS2C with clientbound(_) {
  true
}
