///|
/// Set Player Inventory Slot packet (0x65)
/// Sets player inventory slot
struct SetPlayerInventorySlotS2C {
  slot : Int16 // Slot index
  slot_data : String // Item data
}
///|
impl @mc.Packet for SetPlayerInventorySlotS2C with clientbound(self) {
  true
}