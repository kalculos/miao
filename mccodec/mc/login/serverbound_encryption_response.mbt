///|
/// Encryption Response packet (0x01)
/// Client's response to encryption request
pub(all) struct EncryptionResponseC2S {
  shared_secret : FixedArray[Byte] // Shared secret encrypted with server's public key
  verify_token : FixedArray[Byte] // Verify token encrypted with same public key
}

///|
pub impl @mc.Packet for EncryptionResponseC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for EncryptionResponseC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_prefix_array(
    buf,
    self.shared_secret,
    @buffer.ByteSlice::write_byte,
  )
  @types.write_prefix_array(
    buf,
    self.verify_token,
    @buffer.ByteSlice::write_byte,
  )
}

///|
pub impl @mc.Packet for EncryptionResponseC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  let shared_secret = @types.read_prefix_array(buf, b => b
    .read_byte())
  let verify_token = @types.read_prefix_array(buf, b => b
    .read_byte())
  { shared_secret, verify_token }
}
