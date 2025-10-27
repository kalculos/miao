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
