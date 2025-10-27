///|
/// Set Container Content packet (0x12)
/// Sets all slots in container
struct SetContainerContentS2C {
  window_id : Byte // Window ID
  state_id : Int // State ID
  slots : Array[String] // Slot data (ItemStack format)
  carried_item : String // Item being carried
}
///|
impl @mc.Packet for SetContainerContentS2C with clientbound(self) {
  true
}