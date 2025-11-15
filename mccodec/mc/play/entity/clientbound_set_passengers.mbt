///|
/// Set Passengers packet (0x64)
/// Sets entity passengers
pub(all) struct SetPassengersS2C {
  entity_id : Int // Vehicle entity ID
  passenger_ids : Array[Int] // Passenger entity IDs
}

///|
pub impl @mc.Packet for SetPassengersS2C with clientbound(_) {
  true
}
