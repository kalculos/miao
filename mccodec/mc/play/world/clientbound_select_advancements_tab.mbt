///|
/// Select Advancements Tab packet (0x4E)
/// Selects advancement tab
pub(all) struct SelectAdvancementsTabS2C {
  identifier : String? // Tab identifier (null to close)
}
///|
pub impl @mc.Packet for SelectAdvancementsTabS2C with clientbound(_) {
  true
}