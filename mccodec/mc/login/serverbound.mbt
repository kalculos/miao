///|
/// Login Start packet (0x00)
/// Initial packet sent by client to start login process
struct LoginStartC2S {
  name : String // Player's username (16 chars max)
  player_uuid : @uuid.UUID // UUID of the player logging in (unused by vanilla)
}

///|
impl @mc.Packet for LoginStartC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for LoginStartC2S with serialize(self, buf : &@bytebuf.ByteBuf) {
  @types.write_string(buf, self.name)
  @types.write_uuid(buf, self.player_uuid)
}

///|
impl @mc.Packet for LoginStartC2S with deserialize(buf : &@bytebuf.ByteBuf) {
  let name = @types.read_string(buf)
  let player_uuid = @types.read_uuid(buf)
  { name, player_uuid }
}

///|
/// Encryption Response packet (0x01)
/// Client's response to encryption request
struct EncryptionResponseC2S {
  shared_secret : FixedArray[Byte] // Shared secret encrypted with server's public key
  verify_token : FixedArray[Byte] // Verify token encrypted with same public key
}

///|
impl @mc.Packet for EncryptionResponseC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for EncryptionResponseC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_prefix_array(
    buf,
    self.shared_secret,
    @bytebuf.ByteWriter::write_byte,
  )
  @types.write_prefix_array(
    buf,
    self.verify_token,
    @bytebuf.ByteWriter::write_byte,
  )
}

///|
impl @mc.Packet for EncryptionResponseC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let shared_secret = @types.read_prefix_array(buf, b => b
    .read_byte()
    .unwrap_or(0))
  let verify_token = @types.read_prefix_array(buf, b => b
    .read_byte()
    .unwrap_or(0))
  { shared_secret, verify_token }
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
impl @mc.Packet for LoginPluginResponseC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_varint(buf, self.message_id)
  @types.write_optional(buf, self.data, (b, d) => b.write_bytes(
    Bytes::from_array(d),
  ))
}

///|
impl @mc.Packet for LoginPluginResponseC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let message_id = @types.read_varint(buf)
  let data = @types.read_optional(buf, b => {
    let remaining = b.remaining()
    let bytes = b.read_bytes(remaining).unwrap().to_array()
    bytes
  })
  { message_id, data }
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
impl @mc.Packet for LoginAcknowledgedC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  // No fields to serialize
}

///|
impl @mc.Packet for LoginAcknowledgedC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  LoginAcknowledgedC2S::{  } // No fields to deserialize
}

///|
/// Cookie Response (login) packet (0x04)
/// Response to cookie request during login
struct CookieResponseLoginC2S {
  key : String // Identifier of the cookie, TODO: Identifier type
  payload : FixedArray[Byte]? // Cookie data (up to 5 kiB)
}

///|
impl @mc.Packet for CookieResponseLoginC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for CookieResponseLoginC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.key)
  @types.write_optional(buf, self.payload, (b, p) => @types.write_prefix_array(
    b,
    p,
    @bytebuf.ByteWriter::write_byte,
  ))
}

///|
impl @mc.Packet for CookieResponseLoginC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let key = @types.read_string(buf)
  let payload = @types.read_optional(buf, b => @types.read_prefix_array(b, by => by
    .read_byte()
    .unwrap_or(0)))
  { key, payload }
}
