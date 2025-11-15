///|
/// Player Abilities (clientbound) packet (0x39)
/// Updates player abilities
pub(all) struct PlayerAbilitiesS2C {
  flags : Byte // Ability flags
  flying_speed : Float // Flying speed
  field_of_view_modifier : Float // FOV modifier
}

///|
pub impl @mc.Packet for PlayerAbilitiesS2C with clientbound(_) {
  true
}
