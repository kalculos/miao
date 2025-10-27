///|
/// Open Book packet (0x33)
/// Opens book interface
struct OpenBookS2C {
  hand : Int // Hand holding book
}
///|
impl @mc.Packet for OpenBookS2C with clientbound(self) {
  true
}