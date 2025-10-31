///|
/// Status Response packet (0x00)
/// Sent in response to Status Request, contains server information as JSON
struct StatusResponseS2C {
  json_response : Json
}

///|
impl @mc.Packet for StatusResponseS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for StatusResponseS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_string(buf, self.json_response.to_string())
}

///|
impl @mc.Packet for StatusResponseS2C with deserialize(buf : &@buffer.Buffer) {
  let json_str = @types.read_string(buf)
  { json_response: @json.parse(json_str) }
}
