///|
/// Set Cursor Item packet (0x59)
/// Sets cursor item
struct SetCursorItemS2C {
  slot_data : String // Item data
}
///|
impl @mc.Packet for SetCursorItemS2C with clientbound(self) {
  true
}