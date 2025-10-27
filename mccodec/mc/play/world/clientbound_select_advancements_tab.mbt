///|
/// Select Advancements Tab packet (0x4E)
/// Selects advancement tab
struct SelectAdvancementsTabS2C {
  identifier : String? // Tab identifier (null to close)
}
///|
impl @mc.Packet for SelectAdvancementsTabS2C with clientbound(self) {
  true
}