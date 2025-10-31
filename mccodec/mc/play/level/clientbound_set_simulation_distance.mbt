///|
/// Set Simulation Distance packet (0x68)
/// Sets simulation distance
struct SetSimulationDistanceS2C {
  simulation_distance : Int // Simulation distance
}
///|
impl @mc.Packet for SetSimulationDistanceS2C with clientbound(self) {
  true
}