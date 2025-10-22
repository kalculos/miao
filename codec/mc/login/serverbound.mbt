///|
/// Login Start packet (0x00)
/// Initial packet sent by client to start login process
struct LoginStartC2S {
  name : String // Player's username (16 chars max)
  player_uuid : String // UUID of the player logging in (unused by vanilla)
}

///|
impl @mc.Packet for LoginStartC2S with clientbound(self) {
  false
}

///|
/// Encryption Response packet (0x01)
/// Client's response to encryption request
struct EncryptionResponseC2S {
  shared_secret : Array[Byte] // Shared secret encrypted with server's public key
  verify_token : Array[Byte] // Verify token encrypted with same public key
}

///|
impl @mc.Packet for EncryptionResponseC2S with clientbound(self) {
  false
}

///|
/// Login Plugin Response packet (0x02)
/// Response to login plugin request
struct LoginPluginResponseC2S {
  message_id : Int // Should match ID from server
  data : Array[Byte]? // Plugin data if client understood the request
}

///|
impl @mc.Packet for LoginPluginResponseC2S with clientbound(self) {
  false
}

///|
/// Login Acknowledged packet (0x03)
/// Acknowledges Login Success, switches to configuration state
struct LoginAcknowledgedC2S {}

///|
impl @mc.Packet for LoginAcknowledgedC2S with clientbound(self) {
  false
}

///|
/// Cookie Response (login) packet (0x04)
/// Response to cookie request during login
struct CookieResponseLoginC2S {
  key : String // Identifier of the cookie
  payload : Array[Byte] // Cookie data (up to 5 kiB)
}

///|
impl @mc.Packet for CookieResponseLoginC2S with clientbound(self) {
  false
}
