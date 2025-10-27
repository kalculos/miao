///|
/// Update Teams packet (0x66)
/// Updates scoreboard teams
struct UpdateTeamsS2C {
  team_name : String // Team name
  mode : Byte // Mode (0=create, 1=remove, 2=update_info, 3=add_entities, 4=remove_entities)
  display_name : String? // Team display name
  prefix : String? // Team prefix
  suffix : String? // Team suffix
  friendly_flags : Byte? // Friendly fire flags
  name_tag_visibility : String? // Name tag visibility
  collision_rule : String? // Collision rule
  color : Int? // Team color
  entities : Array[String]? // Entity names
}
///|
impl @mc.Packet for UpdateTeamsS2C with clientbound(self) {
  true
}