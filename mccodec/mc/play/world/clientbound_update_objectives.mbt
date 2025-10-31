///|
/// Update Objectives packet (0x63)
/// Updates scoreboard objectives
struct UpdateObjectivesS2C {
  objective_name : String // Objective name
  mode : Byte // Mode (0=create, 1=remove, 2=update)
  objective_display_name : String? // Display name (for create/update)
  render_type : Int? // Render type (for create/update)
  number_format : String? // Number format (for create/update)
}
///|
impl @mc.Packet for UpdateObjectivesS2C with clientbound(self) {
  true
}