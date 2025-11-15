///|
/// Remove Resource Pack (play) packet (0x49)
/// Removes resource pack
pub(all) struct RemoveResourcePackPlayS2C {
  uuid : String? // Pack UUID (null for all)
}

///|
pub impl @mc.Packet for RemoveResourcePackPlayS2C with clientbound(_) {
  true
}
