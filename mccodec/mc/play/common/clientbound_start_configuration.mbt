///|
/// Start Configuration packet (0x6F)
/// Starts configuration phase
struct StartConfigurationS2C {}
///|
impl @mc.Packet for StartConfigurationS2C with clientbound(self) {
  true
}