///|
/// Recipe Book Settings packet (0x45)
/// Updates recipe book settings
pub(all) struct RecipeBookSettingsS2C {
  crafting_recipe_book_open : Bool // Crafting book open
  crafting_recipe_book_filter_active : Bool // Crafting filter active
  smelting_recipe_book_open : Bool // Smelting book open
  smelting_recipe_book_filter_active : Bool // Smelting filter active
  blast_furnace_recipe_book_open : Bool // Blast furnace book open
  blast_furnace_recipe_book_filter_active : Bool // Blast furnace filter active
  smoker_recipe_book_open : Bool // Smoker book open
  smoker_recipe_book_filter_active : Bool // Smoker filter active
}

///|
pub impl @mc.Packet for RecipeBookSettingsS2C with clientbound(_) {
  true
}
