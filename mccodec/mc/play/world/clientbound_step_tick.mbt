///|
/// Step Tick packet (0x79)
/// Steps world tick
struct StepTickS2C {
  tick_steps : Int // Number of ticks to step
}
///|
impl @mc.Packet for StepTickS2C with clientbound(self) {
  true
}