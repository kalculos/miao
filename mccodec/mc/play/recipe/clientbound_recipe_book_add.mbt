///|
/// Recipe Book Add packet (0x43)
/// Adds recipes to recipe book
pub(all) struct RecipeBookAddS2C {
  recipes : Array[String] // Recipe identifiers
  replace : Bool // Replace existing recipes
}
///|
pub impl @mc.Packet for RecipeBookAddS2C with clientbound(_) {
  true
}