///|
/// Add Resource Pack (play) packet (0x4A)
/// Adds resource pack
pub(all) struct AddResourcePackPlayS2C {
  uuid : String // Pack UUID
  url : String // Pack URL
  hash : String // Pack hash
  forced : Bool // Force pack
  prompt_message : String? // Prompt message
}
///|
pub impl @mc.Packet for AddResourcePackPlayS2C with clientbound(_) {
  true
}