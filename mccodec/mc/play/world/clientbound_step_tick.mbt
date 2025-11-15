///|
/// Step Tick packet (0x79)
/// Steps world tick
pub(all) struct StepTickS2C {
  tick_steps : Int // Number of ticks to step
}

///|
pub impl @mc.Packet for StepTickS2C with clientbound(_) {
  true
}
