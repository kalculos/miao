///|
/// Set Container Slot packet (0x14)
/// Updates single container slot
struct SetContainerSlotS2C {
  window_id : Byte // Window ID
  state_id : Int // State ID
  slot : Int16 // Slot index
  slot_data : String // Slot item data
}
///|
impl @mc.Packet for SetContainerSlotS2C with clientbound(self) {
  true
}