///|
/// End Combat packet (0x3B)
/// Ends combat state
struct EndCombatS2C {
  duration : Int // Combat duration in ticks
}
///|
impl @mc.Packet for EndCombatS2C with clientbound(self) {
  true
}