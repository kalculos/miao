///|
/// End Combat packet (0x3B)
/// Ends combat state
pub(all) struct EndCombatS2C {
  duration : Int // Combat duration in ticks
}

///|
pub impl @mc.Packet for EndCombatS2C with clientbound(_) {
  true
}
