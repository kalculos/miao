///|
/// Player Session packet (0x09)
/// Updates player session info
struct PlayerSessionC2S {
  session_uuid : @uuid.UUID // Session UUID
  expires_at : Int64 // Expiration timestamp
  public_key : FixedArray[Byte] // Public key data
  key_signature : FixedArray[Byte] // Key signature
}

///|
impl @mc.Packet for PlayerSessionC2S with clientbound(self) {
  false
}

impl @mc.Packet for PlayerSessionC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_uuid(buf, self.session_uuid)
  buf.write_int64(self.expires_at)
  @types.write_prefix_array(buf, self.public_key, @bytebuf.ByteWriter::write_byte)
  @types.write_prefix_array(buf, self.key_signature, @bytebuf.ByteWriter::write_byte)
}

impl @mc.Packet for PlayerSessionC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let session_uuid = @types.read_uuid(buf)
  let expires_at = buf.read_int64().unwrap()
  let public_key = @types.read_prefix_array(buf, by => by.read_byte().unwrap())
  let key_signature = @types.read_prefix_array(buf, by => by.read_byte().unwrap())
  { session_uuid, expires_at, public_key, key_signature }
}

