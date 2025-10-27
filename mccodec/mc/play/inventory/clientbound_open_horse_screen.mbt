///|
/// Open Horse Screen packet (0x23)
/// Opens horse inventory
struct OpenHorseScreenS2C {
  window_id : Byte // Window ID
  slot_count : Int // Number of slots
  entity_id : Int // Horse entity ID
}
///|
impl @mc.Packet for OpenHorseScreenS2C with clientbound(self) {
  true
}