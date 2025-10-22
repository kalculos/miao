///|
/// Status Response packet (0x00)
/// Sent in response to Status Request, contains server information as JSON
struct StatusResponseS2C {
  json_response : String
}

///|
impl @mc.Packet for StatusResponseS2C with clientbound(self) {
  true
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
