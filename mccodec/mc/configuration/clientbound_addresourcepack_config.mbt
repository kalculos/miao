///|
/// Add Resource Pack (configuration) packet (0x09)
/// Adds a resource pack to client
pub(all) struct AddResourcePackConfigS2C {
  uuid : @uuid.UUID // Unique identifier of resource pack
  url : String // URL to the resource pack
  hash : String // SHA-1 hash (40 chars)
  forced : Bool // Whether client must use the pack
  prompt_message : String? // Prompt message (if present), TODO: Text Component type
}

///|
pub impl @mc.Packet for AddResourcePackConfigS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for AddResourcePackConfigS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_uuid(buf, self.uuid)
  @types.write_string(buf, self.url)
  @types.write_string(buf, self.hash)
  @types.write_bool(buf, self.forced)
  @types.write_optional(buf, self.prompt_message, @types.write_string)
}

///|
pub impl @mc.Packet for AddResourcePackConfigS2C with deserialize(
  buf : &@buffer.Buffer,
) {
  let uuid = @types.read_uuid(buf)
  let url = @types.read_string(buf)
  let hash = @types.read_string(buf)
  let forced = @types.read_bool(buf)
  let prompt_message = @types.read_optional(buf, @types.read_string)
  { uuid, url, hash, forced, prompt_message }
}

