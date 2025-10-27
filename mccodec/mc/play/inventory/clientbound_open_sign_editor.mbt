///|
/// Open Sign Editor packet (0x35)
/// Opens sign editing interface
struct OpenSignEditorS2C {
  location : (Int, Int, Int) // Sign position
  is_front_text : Bool // Whether editing front text
}
///|
impl @mc.Packet for OpenSignEditorS2C with clientbound(self) {
  true
}