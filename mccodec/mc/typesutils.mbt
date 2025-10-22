// Utility functions for handling Minecraft protocol data types
// https://minecraft.wiki/w/Java_Edition_protocol/Packets#Type

///|
/// Read a variable-length integer from the buffer.
/// This is a common pattern in Minecraft protocols.
pub fn read_varint(buf : &@bytebuf.ByteBuf) -> Int raise {
  let mut value : Int = 0
  let mut position = 0
  let mut byte : Byte = 0
  while true {
    byte = buf.read_byte().unwrap_or(0)
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
/// Read a variable-length long integer from the buffer.
pub fn read_varlong(buf : &@bytebuf.ByteBuf) -> Int64 raise {
  let mut value : Int64 = 0L
  let mut position = 0
  let mut byte : Byte = 0
  while true {
    byte = buf.read_byte().unwrap_or(0)
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
/// Write a variable-length integer to the buffer.
pub fn write_varint(buf : &@bytebuf.ByteBuf, value : Int) -> Unit {
  let mut v = value
  while true {
    if (v & 0xFFFFFF80) == 0 {
      buf.write_byte(v.to_byte())
      return
    }
    buf.write_byte(((v & 0x7F) | 0x80).to_byte())
    v = v >> 7
  }
}

///|
/// Write a variable-length long integer to the buffer.
pub fn write_varlong(buf : &@bytebuf.ByteBuf, value : Int64) -> Unit {
  let mut v = value
  while true {
    if (v & 0xFFFFFFFFFFFFFF80L) == 0L {
      buf.write_byte(v.to_byte())
      return
    }
    buf.write_byte(((v & 0x7FL) | 0x80L).to_byte())
    v = v >> 7
  }
}

///|
/// Read a length-prefixed UTF-8 string from the buffer.
pub fn read_string(buf : &@bytebuf.ByteBuf) -> String raise {
  let length = read_varint(buf)
  if length < 0 {
    raise fail("String length is negative")
  }
  let bytes = buf.read_bytes(length).unwrap_or(Bytes::make(0, 0))
  if bytes.length() != length {
    raise fail("Not enough bytes to read the string")
  }
  @encoding/utf8.decode(bytes)
}

///|
/// Write a length-prefixed UTF-8 string to the buffer.
pub fn write_string(buf : &@bytebuf.ByteBuf, str : String) -> Unit {
  let bytes = @encoding/utf8.encode(str)
  write_varint(buf, bytes.length())
  buf.write_bytes(bytes)
}

///|
/// Read an unsigned short (2 bytes) from the buffer.
pub fn read_ushort(buf : &@bytebuf.ByteBuf) -> Int {
  let byte1 = buf.read_byte().unwrap_or(0).to_int()
  let byte2 = buf.read_byte().unwrap_or(0).to_int()
  (byte1 << 8) | byte2
}

///|
/// Write an unsigned short (2 bytes) to the buffer.
pub fn write_ushort(buf : &@bytebuf.ByteBuf, value : Int) -> Unit {
  buf.write_byte((value >> 8).to_byte())
  buf.write_byte(value.to_byte())
}

///|
/// Read a signed short (2 bytes) from the buffer.
pub fn read_short(buf : &@bytebuf.ByteBuf) -> Int {
  let unsigned = read_ushort(buf)
  if unsigned >= 0x8000 {
    unsigned - 0x10000
  } else {
    unsigned
  }
}

///|
/// Write a signed short (2 bytes) to the buffer.
pub fn write_short(buf : &@bytebuf.ByteBuf, value : Int) -> Unit {
  let unsigned = if value < 0 { value + 0x10000 } else { value }
  write_ushort(buf, unsigned)
}

///|
/// Read an unsigned int (4 bytes) from the buffer.
pub fn read_uint(buf : &@bytebuf.ByteBuf) -> Int64 {
  let byte1 = buf.read_byte().unwrap_or(0).to_int64()
  let byte2 = buf.read_byte().unwrap_or(0).to_int64()
  let byte3 = buf.read_byte().unwrap_or(0).to_int64()
  let byte4 = buf.read_byte().unwrap_or(0).to_int64()
  (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4
}

///|
/// Write an unsigned int (4 bytes) to the buffer.
pub fn write_uint(buf : &@bytebuf.ByteBuf, value : Int64) -> Unit {
  buf.write_byte((value >> 24).to_byte())
  buf.write_byte((value >> 16).to_byte())
  buf.write_byte((value >> 8).to_byte())
  buf.write_byte(value.to_byte())
}

///|
/// Read a signed int (4 bytes) from the buffer.
pub fn read_int(buf : &@bytebuf.ByteBuf) -> Int {
  let byte1 = buf.read_byte().unwrap_or(0).to_int()
  let byte2 = buf.read_byte().unwrap_or(0).to_int()
  let byte3 = buf.read_byte().unwrap_or(0).to_int()
  let byte4 = buf.read_byte().unwrap_or(0).to_int()
  (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4
}

///|
/// Write a signed int (4 bytes) to the buffer.
pub fn write_int(buf : &@bytebuf.ByteBuf, value : Int) -> Unit {
  buf.write_byte((value >> 24).to_byte())
  buf.write_byte((value >> 16).to_byte())
  buf.write_byte((value >> 8).to_byte())
  buf.write_byte(value.to_byte())
}

///|
/// Read a long (8 bytes) from the buffer.
pub fn read_long(buf : &@bytebuf.ByteBuf) -> Int64 {
  let mut result : Int64 = 0L
  for i = 0; i < 8; i = i + 1 {
    let byte_val = buf.read_byte().unwrap_or(0).to_int64()
    result = (result << 8) | byte_val
  }
  result
}

///|
/// Write a long (8 bytes) to the buffer.
pub fn write_long(buf : &@bytebuf.ByteBuf, value : Int64) -> Unit {
  for i = 7; i >= 0; i = i - 1 {
    buf.write_byte((value >> (i * 8)).to_byte())
  }
}

///|
/// Read a float (4 bytes) from the buffer.
pub fn read_float(buf : &@bytebuf.ByteBuf) -> Float {
  let _int_value = read_int(buf)
  // TODO: Implement proper float conversion
  0.0
}

///|
/// Write a float (4 bytes) to the buffer.
pub fn write_float(buf : &@bytebuf.ByteBuf, _value : Float) -> Unit {
  // TODO: Implement proper float conversion
  write_int(buf, 0)
}

///|
/// Read a double (8 bytes) from the buffer.
pub fn read_double(buf : &@bytebuf.ByteBuf) -> Double {
  let _long_value = read_long(buf)
  // TODO: Implement proper double conversion
  0.0
}

///|
/// Write a double (8 bytes) to the buffer.
pub fn write_double(buf : &@bytebuf.ByteBuf, _value : Double) -> Unit {
  // TODO: Implement proper double conversion
  write_long(buf, 0L)
}

///|
/// Read a boolean from the buffer.
pub fn read_bool(buf : &@bytebuf.ByteBuf) -> Bool {
  let byte_val = buf.read_byte().unwrap_or(0)
  byte_val != 0
}

///|
/// Write a boolean to the buffer.
pub fn write_bool(buf : &@bytebuf.ByteBuf, value : Bool) -> Unit {
  buf.write_byte(if value { 1 } else { 0 })
}

///|
/// Read a UUID (16 bytes) from the buffer.
pub fn read_uuid(buf : &@bytebuf.ByteBuf) -> String {
  let _most_significant = read_long(buf)
  let _least_significant = read_long(buf)
  // TODO: Implement proper UUID string formatting
  "00000000-0000-0000-0000-000000000000"
}

///|
/// Write a UUID (16 bytes) to the buffer.
pub fn write_uuid(buf : &@bytebuf.ByteBuf, _uuid : String) -> Unit {
  // TODO: Implement proper UUID string parsing
  // For now, write zeros
  write_long(buf, 0L)
  write_long(buf, 0L)
}

///|
/// Read NBT data from the buffer.
pub fn read_nbt(_buf : &@bytebuf.ByteBuf) -> @nbt.NBTTag raise {
  // TODO: Implement NBT reading
  raise fail("NBT reading not implemented yet")
}

///|
/// Write NBT data to the buffer.
pub fn write_nbt(_buf : &@bytebuf.ByteBuf, _nbt : @nbt.NBTTag) -> Unit raise {
  // TODO: Implement NBT writing
  raise fail("NBT writing not implemented yet")
}
