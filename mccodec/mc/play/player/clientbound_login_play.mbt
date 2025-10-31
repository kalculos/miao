///|
/// Login (play) packet (0x2B)
/// Initial login data for play state
struct LoginPlayS2C {
  entity_id : Int // Player entity ID
  is_hardcore : Bool // Hardcore mode
  dimensions : Array[String] // Available dimensions
  max_players : Int // Max players
  view_distance : Int // View distance
  simulation_distance : Int // Simulation distance
  reduced_debug_info : Bool // Reduced debug info
  enable_respawn_screen : Bool // Enable respawn screen
  do_limited_crafting : Bool // Limited crafting
  dimension_type : String // Dimension type
  dimension_name : String // Dimension name
  hashed_seed : Int64 // World seed hash
  game_mode : Byte // Game mode
  previous_game_mode : Byte // Previous game mode
  is_debug : Bool // Debug world
  is_flat : Bool // Flat world
  death_location : (String, Int, Int, Int)? // Death dimension and position
  portal_cooldown : Int // Portal cooldown
  sea_level : Int // Sea level
  enforces_secure_chat : Bool // Secure chat enforcement
}
///|
impl @mc.Packet for LoginPlayS2C with clientbound(self) {
  true
}