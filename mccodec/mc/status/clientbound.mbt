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
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.json_response.to_string())
}

///|
impl @mc.Packet for StatusResponseS2C with deserialize(buf : &@bytebuf.ByteBuf) {
  let json_str = @types.read_string(buf)
  { json_response: @json.parse(json_str) }
}

///|
/// Pong Response packet (0x01)  
/// Sent in response to Ping Request, echoes back the timestamp
struct PongResponseS2C {
  timestamp : Int64
}

///|
impl @mc.Packet for PongResponseS2C with clientbound(self) {
  true
}

///|
impl @mc.Packet for PongResponseS2C with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  buf.write_int64(self.timestamp)
}

///|
impl @mc.Packet for PongResponseS2C with deserialize(buf : &@bytebuf.ByteBuf) {
  { timestamp: buf.read_int64().unwrap() }
}
