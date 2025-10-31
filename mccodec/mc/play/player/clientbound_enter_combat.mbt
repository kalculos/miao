///|
/// Enter Combat packet (0x3C)
/// Enters combat state
struct EnterCombatS2C {}
///|
impl @mc.Packet for EnterCombatS2C with clientbound(self) {
  true
}