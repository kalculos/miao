///|
struct Property {
  name : String
  value : String
  signature : String?
}

///|
pub fn read_property(buf : &@buffer.Buffer) -> Property raise {
  let name = read_string(buf)
  let value = read_string(buf)
  let signature = read_optional(buf, read_string)
  { name, value, signature }
}

///|
pub fn write_property(buf : &@buffer.Buffer, property : Property) -> Unit {
  write_string(buf, property.name)
  write_string(buf, property.value)
  write_optional(buf, property.signature, write_string)
}

///|
struct GameProfile {
  uuid : @uuid.UUID
  username : String
  properties : FixedArray[Property]
}

///|
pub fn read_game_profile(buf : &@buffer.Buffer) -> GameProfile raise {
  let uuid = read_uuid(buf)
  let username = read_string(buf)
  let properties = read_prefix_array(buf, read_property)
  { uuid, username, properties }
}

///|
pub fn write_game_profile(
  buf : &@buffer.Buffer,
  profile : GameProfile,
) -> Unit {
  write_uuid(buf, profile.uuid)
  write_string(buf, profile.username)
  write_prefix_array(buf, profile.properties, write_property)
}
