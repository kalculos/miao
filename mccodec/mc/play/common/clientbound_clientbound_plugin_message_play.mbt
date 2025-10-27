///|
/// Clientbound Plugin Message (play) packet (0x18)
/// Plugin message from server
struct ClientboundPluginMessagePlayS2C {
  channel : String // Plugin channel
  data : Array[Byte] // Plugin data
}
///|
impl @mc.Packet for ClientboundPluginMessagePlayS2C with clientbound(self) {
  true
}