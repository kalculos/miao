///|
/// Player Chat Message packet (0x3A)
/// Player chat message
pub(all) struct PlayerChatMessageS2C {
  // Header section
  global_index : Int
  sender : @uuid.UUID // Sender UUID
  index : Int // Message index
  message_signature : FixedArray[Byte]? // Message signature, fixed 256 bytes, optional
  // Body section
  message : String // Message content
  timestamp : Int64 // Message timestamp
  salt : Int64 // Random salt
  // previous messages
  previous_messages : Map[Int, FixedArray[Byte]] // Previous message signatures, max 20 entries
  // other
  unsigned_content : String? // Unsigned content, TODO: Text Component
  filter_type : Int // Filter type, enum
  filter_type_bitset : @types.BitSet? // Filter type bitset
  // chat formatting
  chat_type : @types.Holder[@types.ChatType] // Chat type
  sender_name : String // Sender display name, TODO: Text Component
  target_name : String? // Target display name, TODO: Text Component
}

///|
pub impl @mc.Packet for PlayerChatMessageS2C with clientbound(_) {
  true
}

///|
pub impl @mc.Packet for PlayerChatMessageS2C with serialize(
  self,
  buf : &@buffer.Buffer,
) raise {
  // Header section
  @types.write_varint(buf, self.global_index)
  @types.write_uuid(buf, self.sender)
  @types.write_varint(buf, self.index)
  @types.write_optional(buf, self.message_signature, (b, sig) => b.write(
      sig, 0, 256,
    )
    |> ignore)
  // Body section
  @types.write_string(buf, self.message)
  buf.write_int64(self.timestamp)
  buf.write_int64(self.salt)
  // previous messages
  @types.write_map(buf, self.previous_messages, @types.write_varint, (buf, sig) => buf.write(
    sig, 0, 256,
  ) |> ignore)
  // other
  @types.write_optional(buf, self.unsigned_content, @types.write_string)
  @types.write_varint(buf, self.filter_type)
  @types.write_optional(buf, self.filter_type_bitset, (b, bitset) => @types.write_bitset(
    b, bitset,
  ))
  // chat formatting
  @types.write_holder(buf, self.chat_type, @types.write_chat_type)
  @types.write_string(buf, self.sender_name)
  @types.write_optional(buf, self.target_name, @types.write_string)
}

///|
pub impl @mc.Packet for PlayerChatMessageS2C with deserialize(
  buf : &@buffer.Buffer,
) raise {
  // Header section
  let global_index = @types.read_varint(buf)
  let sender = @types.read_uuid(buf)
  let index = @types.read_varint(buf)
  let message_signature = @types.read_optional(buf, buf => buf
    .read_bytes(256)
    .to_fixedarray())
  // Body section
  let message = @types.read_string(buf)
  let timestamp = buf.read_int64()
  let salt = buf.read_int64()
  // previous messages
  let previous_messages = @types.read_map(buf, @types.read_varint, buf => buf
    .read_bytes(256)
    .to_fixedarray())
  // other
  let unsigned_content = @types.read_optional(buf, @types.read_string)
  let filter_type = @types.read_varint(buf)
  let filter_type_bitset = @types.read_optional(buf, @types.read_bitset)
  // chat formatting
  let chat_type = @types.read_holder(buf, @types.read_chat_type)
  let sender_name = @types.read_string(buf)
  let target_name = @types.read_optional(buf, @types.read_string)
  {
    global_index,
    sender,
    index,
    message_signature,
    message,
    timestamp,
    salt,
    previous_messages,
    unsigned_content,
    filter_type,
    filter_type_bitset,
    chat_type,
    sender_name,
    target_name,
  }
}
