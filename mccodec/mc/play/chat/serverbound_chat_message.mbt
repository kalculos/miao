///|
/// Chat Message packet (0x08)
/// Sends chat message
struct ChatMessageC2S {
  message : String // Chat message content
  timestamp : Int64 // Message timestamp
  salt : Int64 // Random salt
  signature : FixedArray[Byte]? // Message signature, fixed 256 bytes, optional
  message_count : Int // Message count
  acknowledged : @types.BitSet // Acknowledged messages
  checksum : Byte // Checksum
}

///|
impl @mc.Packet for ChatMessageC2S with clientbound(self) {
  false
}

///|
impl @mc.Packet for ChatMessageC2S with serialize(self, buf : &@buffer.Buffer) {
  @types.write_string(buf, self.message)
  buf.write_int64(self.timestamp)
  buf.write_int64(self.salt)
  @types.write_optional(buf, self.signature, (b, sig) => b.write_array(
    sig, 0, 256,
  ))
  @types.write_varint(buf, self.message_count)
  // Write acknowledged as byte array
  @types.write_fixed_bitset(buf, self.acknowledged, 20)
  buf.write_byte(self.checksum)
}

///|
impl @mc.Packet for ChatMessageC2S with deserialize(buf : &@buffer.Buffer) {
  let message = @types.read_string(buf)
  let timestamp = buf.read_int64().unwrap()
  let salt = buf.read_int64().unwrap()
  let signature = @types.read_optional(buf, b => b
    .read_bytes(256)
    .unwrap()
    .to_fixedarray())
  let message_count = @types.read_varint(buf)
  // Read acknowledged as byte array
  let acknowledged = @types.read_fixed_bitset(buf, 20)
  let checksum = buf.read_byte().unwrap()
  { message, timestamp, salt, signature, message_count, acknowledged, checksum }
}
