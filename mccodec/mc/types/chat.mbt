///|
struct ChatTypeDecoration {
  translation_key : String
  parameters : FixedArray[Int] // enum parameters, enum(0=sender, 1=target, 2=content)
  style : @nbt.NBTTag
}

///|
pub fn read_chat_type_decoration(
  buf : &@buffer.Buffer,
) -> ChatTypeDecoration raise {
  let translation_key = read_string(buf)
  let parameters = read_prefix_array(buf, read_varint)
  let style = read_nbt(buf)
  { translation_key, parameters, style }
}

///|
pub fn write_chat_type_decoration(
  buf : &@buffer.Buffer,
  decoration : ChatTypeDecoration,
) -> Unit {
  write_string(buf, decoration.translation_key)
  write_prefix_array(buf, decoration.parameters, write_varint)
  write_nbt(buf, decoration.style)
}

///|
struct ChatType {
  chat : ChatTypeDecoration
  narration : ChatTypeDecoration
}

///|
pub fn read_chat_type(buf : &@buffer.Buffer) -> ChatType raise {
  let chat = read_chat_type_decoration(buf)
  let narration = read_chat_type_decoration(buf)
  { chat, narration }
}

///|
pub fn write_chat_type(buf : &@buffer.Buffer, chat_type : ChatType) -> Unit {
  write_chat_type_decoration(buf, chat_type.chat)
  write_chat_type_decoration(buf, chat_type.narration)
}
