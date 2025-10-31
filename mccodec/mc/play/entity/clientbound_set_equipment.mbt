///|
/// Set Equipment packet (0x5F)
/// Sets entity equipment
struct SetEquipmentS2C {
  entity_id : Int // Entity ID
  equipment : Array[(Byte, String)] // (Slot, Item) pairs
}
///|
impl @mc.Packet for SetEquipmentS2C with clientbound(self) {
  true
}