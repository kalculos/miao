///|
/// World Event packet (0x28)
/// Plays world event effect
pub(all) struct WorldEventS2C {
  event : Int // Event ID
  location : (Int, Int, Int) // Event location
  data : Int // Event data
  disable_relative_volume : Bool // Volume control
}
///|
pub impl @mc.Packet for WorldEventS2C with clientbound(_) {
  true
}