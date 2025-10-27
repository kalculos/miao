///|
/// Open Screen packet (0x34)
/// Opens GUI screen
struct OpenScreenS2C {
  window_id : Int // Window ID
  window_type : Int // Window type
  window_title : String // Window title
}
///|
impl @mc.Packet for OpenScreenS2C with clientbound(self) {
  true
}