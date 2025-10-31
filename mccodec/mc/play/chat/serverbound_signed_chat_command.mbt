struct ArgumentSignature {
  name : String // Argument name
  signature : FixedArray[Byte] // Argument signature, fixed 256 bytes
}

///|
/// Signed Chat Command packet (0x07)
/// Sends signed chat command
struct SignedChatCommandC2S {
  command : String // Command text
  timestamp : Int64 // Command timestamp
  salt : Int64 // Random salt
  argument_signatures : FixedArray[ArgumentSignature] // Argument signatures
  message_count : Int // Message count
  acknowledged : @types.BitSet // Acknowledged messages
  checksum : Byte // Checksum
}

///|
impl @mc.Packet for SignedChatCommandC2S with clientbound(self) {
  false
}


impl @mc.Packet for SignedChatCommandC2S with serialize(
  self,
  buf : &@bytebuf.ByteBuf,
) {
  @types.write_string(buf, self.command)
  buf.write_int64(self.timestamp)
  buf.write_int64(self.salt)
  @types.write_prefix_array(buf, self.argument_signatures, (b, arg_sig) => {
    @types.write_string(b, arg_sig.name)
    b.write_array(arg_sig.signature, 0, 256)
  })
  @types.write_varint(buf, self.message_count)
  @types.write_fixed_bitset(buf, self.acknowledged, 20)
  buf.write_byte(self.checksum)
}

impl @mc.Packet for SignedChatCommandC2S with deserialize(
  buf : &@bytebuf.ByteBuf,
) {
  let command = @types.read_string(buf)
  let timestamp = buf.read_int64().unwrap()
  let salt = buf.read_int64().unwrap()
  let argument_signatures = @types.read_prefix_array(buf, b => {
    let name = @types.read_string(b)
    let signature = b.read_bytes(256).unwrap().to_fixedarray()
    ArgumentSignature::{ name, signature }
  })
  let message_count = @types.read_varint(buf)
  let acknowledged = @types.read_fixed_bitset(buf, 20)
  let checksum = buf.read_byte().unwrap()
  { command, timestamp, salt, argument_signatures, message_count, acknowledged, checksum }
}
