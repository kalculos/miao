///|
/// Set Cooldown packet (0x16)
/// Sets item cooldown
struct SetCooldownS2C {
  item_id : Int // Item ID
  cooldown_ticks : Int // Cooldown duration in ticks
}
///|
impl @mc.Packet for SetCooldownS2C with clientbound(self) {
  true
}