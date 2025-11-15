///|
/// Move Minecart Along Track packet (0x30)
/// Moves minecart along track
pub(all) struct MoveMinecartAlongTrackS2C {
  entity_id : Int // Minecart entity ID
  steps : Array[(Double, Double, Double, Float, Float)] // Movement steps
}

///|
pub impl @mc.Packet for MoveMinecartAlongTrackS2C with clientbound(_) {
  true
}
