///|
/// Start Configuration packet (0x6F)
/// Starts configuration phase
pub(all) struct StartConfigurationS2C {}

///|
pub impl @mc.Packet for StartConfigurationS2C with clientbound(_) {
  true
}
