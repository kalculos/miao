///|
/// Set Container Property packet (0x13)
/// Updates container property
struct SetContainerPropertyS2C {
  window_id : Byte // Window ID
  property : Int16 // Property ID
  value : Int16 // Property value
}
///|
impl @mc.Packet for SetContainerPropertyS2C with clientbound(self) {
  true
}