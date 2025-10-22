// https://minecraft.wiki/w/Java_Edition_protocol/Packets#Type

///|
pub trait FriendlyByteBuf: @bytebuf.ByteBuf {
  read_varint(Self) -> Int raise
  read_varlong(Self) -> Int64 raise
  read_string(Self) -> String raise
  read_nbt(Self) -> @nbt.NBTTag raise
}

///|
const SEGMENT_BITS : Byte = 0x7F

///|
const CONTINUE_BIT : Byte = 0x80

///|
pub impl FriendlyByteBuf for &@bytebuf.ByteBuf with read_varint(self) -> Int raise {
  // Read a variable-length integer from the buffer.
  // This is a common pattern in Minecraft protocols.
  let mut value: Int = 0
  let mut position = 0
  let mut byte : Byte = 0
  while true {
    byte = self.read_byte().unwrap_or(0)
    value = value | ((byte & SEGMENT_BITS).to_int() << position)
    position = position + 7
    if (byte & CONTINUE_BIT) == 0 {
      break
    }
    if position >= 32 {
      raise fail("VarInt is too big")
    }
  }
  value
}

///|
pub impl FriendlyByteBuf for &@bytebuf.ByteBuf with read_varlong(self) -> Int64 raise {
  // Read a variable-length long integer from the buffer.
  let mut value: Int64 = 0
  let mut position = 0
  let mut byte : Byte = 0
  while true {
    byte = self.read_byte().unwrap_or(0)
    value = value | ((byte & SEGMENT_BITS).to_int64() << position)
    position = position + 7
    if (byte & CONTINUE_BIT) == 0 {
      break
    }
    if position >= 64 {
      raise fail("VarLong is too big")
    }
  }
  value
}

///|
pub impl FriendlyByteBuf for &@bytebuf.ByteBuf with read_string(self) -> String raise {
  // Read a length-prefixed UTF-8 string from the buffer.
  let length = self.read_varint()
  if length < 0 {
    raise fail("String length is negative")
  }
  let bytes = self.read_bytes(length).unwrap_or(Bytes::make(0, 0))
  if bytes.length() != length {
    raise fail("Not enough bytes to read the string")
  }
  @encoding/utf8.decode(bytes)
}

///|
pub impl FriendlyByteBuf for &@bytebuf.ByteBuf with read_nbt(self) -> @nbt.NBTTag raise {
  ... // TODO
}
