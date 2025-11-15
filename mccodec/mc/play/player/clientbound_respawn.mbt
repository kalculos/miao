///|
/// Respawn packet (0x4B)
/// Respawns player
pub(all) struct RespawnS2C {
  dimension_type : String // Dimension type
  dimension_name : String // Dimension name
  hashed_seed : Int64 // World seed hash
  game_mode : Byte // Game mode
  previous_game_mode : Byte // Previous game mode
  is_debug : Bool // Debug world
  is_flat : Bool // Flat world
  copy_metadata : Bool // Copy metadata
  death_location : (String, Int, Int, Int)? // Death location
  portal_cooldown : Int // Portal cooldown
  sea_level : Int // Sea level
}

///|
pub impl @mc.Packet for RespawnS2C with clientbound(_) {
  true
}
