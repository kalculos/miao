///|
/// Delete Message packet (0x1B)
/// Deletes chat message
pub(all) struct DeleteMessageS2C {
  message_id : Int // Message ID to delete
  signature : FixedArray[Byte]? // Message signature, fixed length 256 bytes
}

///|
pub impl @mc.Packet for DeleteMessageS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for DeleteMessageS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  @types.write_varint(buf, self.message_id)
  @types.write_optional(buf, self.signature, (buf, sig) => buf.write(
      sig, 0, 256,
    )
    |> ignore)
}

///|
pub impl @mc.Packet for DeleteMessageS2C with deserialize(buf : &@buffer.Buffer) {
  let message_id = @types.read_varint(buf)
  let signature = @types.read_optional(buf, buf => buf
    .read_bytes(256)
    .to_fixedarray())
  { message_id, signature }
}
