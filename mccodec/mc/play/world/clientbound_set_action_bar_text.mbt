///|
/// Set Action Bar Text packet (0x50)
/// Sets action bar text
pub(all) struct SetActionBarTextS2C {
  text : String // Action bar text
}
///|
pub impl @mc.Packet for SetActionBarTextS2C with clientbound(_) {
  true
}