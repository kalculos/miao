///|
/// Remove Resource Pack (play) packet (0x49)
/// Removes resource pack
struct RemoveResourcePackPlayS2C {
  uuid : String? // Pack UUID (null for all)
}
///|
impl @mc.Packet for RemoveResourcePackPlayS2C with clientbound(self) {
  true
}