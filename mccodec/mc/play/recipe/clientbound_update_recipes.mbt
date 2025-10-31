///|
/// Update Recipes packet (0x7E)
/// Updates recipe data
struct UpdateRecipesS2C {
  property_sets : Array[(String, Array[Int])] // Property sets
  stonecutter_recipes : Array[(String, String)] // Stonecutter recipes
}
///|
impl @mc.Packet for UpdateRecipesS2C with clientbound(self) {
  true
}