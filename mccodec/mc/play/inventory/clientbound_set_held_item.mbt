///|
/// Set Held Item (clientbound) packet (0x62)
/// Sets held item slot
struct SetHeldItemS2C {
  slot : Byte // Selected slot
}
///|
impl @mc.Packet for SetHeldItemS2C with clientbound(self) {
  true
}