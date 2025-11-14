///|
/// Enter Combat packet (0x3C)
/// Enters combat state
pub(all) struct EnterCombatS2C {}
///|
pub impl @mc.Packet for EnterCombatS2C with clientbound(_) {
  true
}