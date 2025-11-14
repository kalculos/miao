///|
/// Set Entity Metadata packet (0x5C)
/// Sets entity metadata
pub(all) struct SetEntityMetadataS2C {
  entity_id : Int // Entity ID
  metadata : Array[String] // Metadata entries
}
///|
pub impl @mc.Packet for SetEntityMetadataS2C with clientbound(_) {
  true
}