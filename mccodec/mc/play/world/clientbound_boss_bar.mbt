///|
/// Boss Bar packet (0x09)
/// Manages boss bars
pub(all) struct BossBarS2C {
  uuid : String // Boss bar UUID
  action : Int // Action type (0=add, 1=remove, 2=update_health, etc)
  title : String? // Boss bar title (for add/update_title)
  health : Float? // Health (0.0-1.0, for add/update_health)
  color : Int? // Color (for add/update_style)
  division : Int? // Division (for add/update_style)
  flags : Byte? // Flags (for add/update_flags)
}

///|
pub impl @mc.Packet for BossBarS2C with clientbound(_) {
  true
}
