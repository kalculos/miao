///|
/// Update Recipes packet (0x7E)
/// Updates recipe data
pub(all) struct UpdateRecipesS2C {
  property_sets : Array[(String, Array[Int])] // Property sets
  stonecutter_recipes : Array[(String, String)] // Stonecutter recipes
}
///|
pub impl @mc.Packet for UpdateRecipesS2C with clientbound(_) {
  true
}