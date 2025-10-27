///|
/// Update Advancements packet (0x7B)
/// Updates advancement data
struct UpdateAdvancementsS2C {
  reset : Bool // Reset advancements
  advancement_mapping : Array[(String, String)] // (ID, Data) pairs
  identifiers : Array[String] // Identifiers to remove
  progress_mapping : Array[(String, String)] // (ID, Progress) pairs
}
///|
impl @mc.Packet for UpdateAdvancementsS2C with clientbound(self) {
  true
}