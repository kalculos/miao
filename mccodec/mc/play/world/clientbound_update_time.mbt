///|
/// Update Time packet (0x6A)
/// Updates world time
pub(all) struct UpdateTimeS2C {
  world_age : Int64 // World age in ticks
  time_of_day : Int64 // Time of day in ticks
}
///|
pub impl @mc.Packet for UpdateTimeS2C with clientbound(_) {
  true
}