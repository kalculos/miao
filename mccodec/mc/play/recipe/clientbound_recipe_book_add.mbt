///|
/// Recipe Book Add packet (0x43)
/// Adds recipes to recipe book
struct RecipeBookAddS2C {
  recipes : Array[String] // Recipe identifiers
  replace : Bool // Replace existing recipes
}
///|
impl @mc.Packet for RecipeBookAddS2C with clientbound(self) {
  true
}