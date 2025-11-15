///|
/// Teleport Entity packet (0x1F)
/// Teleports entity to position
pub(all) struct TeleportEntityS2C {
  entity_id : Int // Entity ID
  x : Double // X position
  y : Double // Y position
  z : Double // Z position
  yaw : Byte // Yaw angle
  pitch : Byte // Pitch angle
  on_ground : Bool // Whether on ground
}

///|
pub impl @mc.Packet for TeleportEntityS2C with clientbound(_) {
  true
}
