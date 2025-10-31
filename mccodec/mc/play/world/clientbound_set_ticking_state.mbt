///|
/// Set Ticking State packet (0x78)
/// Sets world ticking state
struct SetTickingStateS2C {
  tick_rate : Float // Tick rate
  is_frozen : Bool // Whether world is frozen
}
///|
impl @mc.Packet for SetTickingStateS2C with clientbound(self) {
  true
}