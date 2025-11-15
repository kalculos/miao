///|
/// Set Simulation Distance packet (0x68)
/// Sets simulation distance
pub(all) struct SetSimulationDistanceS2C {
  simulation_distance : Int // Simulation distance
}

///|
pub impl @mc.Packet for SetSimulationDistanceS2C with clientbound(_) {
  true
}
