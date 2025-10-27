///|
/// Set Action Bar Text packet (0x50)
/// Sets action bar text
struct SetActionBarTextS2C {
  text : String // Action bar text
}
///|
impl @mc.Packet for SetActionBarTextS2C with clientbound(self) {
  true
}