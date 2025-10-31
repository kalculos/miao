///|
struct ChatTypeDecoration {
  translation_key : String
  parameters : FixedArray[Int] // enum parameters, enum(0=sender, 1=target, 2=content)
  style : @nbt.NBTTag
}

///|
pub fn read_chat_type_decoration(
  buf : &@bytebuf.ByteBuf,
) -> ChatTypeDecoration raise {
  let translation_key = read_string(buf)
  let parameters = read_prefix_array(buf, read_varint)
  let style = read_nbt(buf)
  { translation_key, parameters, style }
}

///|
pub fn write_chat_type_decoration(
  buf : &@bytebuf.ByteBuf,
  decoration : ChatTypeDecoration,
) -> Unit raise {
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
pub fn read_chat_type(buf : &@bytebuf.ByteBuf) -> ChatType raise {
  let chat = read_chat_type_decoration(buf)
  let narration = read_chat_type_decoration(buf)
  { chat, narration }
}

///|
pub fn write_chat_type(
  buf : &@bytebuf.ByteBuf,
  chat_type : ChatType,
) -> Unit raise {
  write_chat_type_decoration(buf, chat_type.chat)
  write_chat_type_decoration(buf, chat_type.narration)
}
