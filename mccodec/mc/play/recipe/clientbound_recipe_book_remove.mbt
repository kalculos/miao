///|
/// Recipe Book Remove packet (0x44)
/// Removes recipes from recipe book
pub(all) struct RecipeBookRemoveS2C {
  recipes : Array[String] // Recipe identifiers to remove
}
///|
pub impl @mc.Packet for RecipeBookRemoveS2C with clientbound(_) {
  true
}