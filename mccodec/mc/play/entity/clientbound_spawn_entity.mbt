///|
/// Spawn Entity packet (0x01)
/// Sent when an entity is created
pub(all) struct SpawnEntityS2C {
  entity_id : Int // Unique entity ID
  entity_uuid : String // UUID of entity
  entity_type : Int // Entity type ID
  x : Double // X position
  y : Double // Y position  
  z : Double // Z position
  pitch : Byte // Pitch angle
  yaw : Byte // Yaw angle
  head_yaw : Byte // Head yaw angle
  data : Int // Entity-specific data
  velocity_x : Int16 // X velocity
  velocity_y : Int16 // Y velocity
  velocity_z : Int16 // Z velocity
}

///|
pub impl @mc.Packet for SpawnEntityS2C with clientbound(_) {
  true
}
