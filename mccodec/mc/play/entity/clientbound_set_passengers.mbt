///|
/// Set Passengers packet (0x64)
/// Sets entity passengers
struct SetPassengersS2C {
  entity_id : Int // Vehicle entity ID
  passenger_ids : Array[Int] // Passenger entity IDs
}
///|
impl @mc.Packet for SetPassengersS2C with clientbound(self) {
  true
}