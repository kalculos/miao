///|
/// Recipe Book Remove packet (0x44)
/// Removes recipes from recipe book
struct RecipeBookRemoveS2C {
  recipes : Array[String] // Recipe identifiers to remove
}
///|
impl @mc.Packet for RecipeBookRemoveS2C with clientbound(self) {
  true
}