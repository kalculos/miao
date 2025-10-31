// Utility functions for handling Minecraft protocol data types
// https://minecraft.wiki/w/Java_Edition_protocol/Packets#Type

///|
const SEGMENT_BITS : Byte = 0x7F

///|
const CONTINUE_BIT : Byte = 0x80

///|
/// Read a variable-length integer from the buffer.
/// This is a common pattern in Minecraft protocols.
pub fn read_varint(buf : &@buffer.Buffer) -> Int raise {
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
/// Write a variable-length integer to the buffer.
pub fn write_varint(buf : &@buffer.Buffer, value : Int) -> Unit {
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
/// Read a variable-length long integer from the buffer.
pub fn read_varlong(buf : &@buffer.Buffer) -> Int64 raise {
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
/// Write a variable-length long integer to the buffer.
pub fn write_varlong(buf : &@buffer.Buffer, value : Int64) -> Unit {
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
/// Read a boolean from the buffer.
pub fn read_bool(buf : &@buffer.Buffer) -> Bool {
  let byte_val = buf.read_byte().unwrap_or(0)
  byte_val != 0
}

///|
/// Write a boolean to the buffer.
pub fn write_bool(buf : &@buffer.Buffer, value : Bool) -> Unit {
  buf.write_byte(if value { 1 } else { 0 })
}

///|
/// Read a length-prefixed UTF-8 string from the buffer.
pub fn read_string(buf : &@buffer.Buffer) -> String raise {
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
pub fn write_string(buf : &@buffer.Buffer, str : String) -> Unit {
  let bytes = @encoding/utf8.encode(str)
  write_varint(buf, bytes.length())
  buf.write_bytes(bytes)
}

///|
/// Read a length-prefixed array from the buffer.
pub fn[T] read_prefix_array(
  buf : &@buffer.Buffer,
  reader : (&@buffer.Buffer) -> T raise,
) -> FixedArray[T] raise {
  let length = read_varint(buf)
  if length < 0 {
    raise fail("Array length is negative")
  }
  FixedArray::makei(length, _ => reader(buf))
}

///|
/// Write a length-prefixed array to the buffer.
pub fn[T] write_prefix_array(
  buf : &@buffer.Buffer,
  arr : FixedArray[T],
  writer : (&@buffer.Buffer, T) -> Unit,
) -> Unit {
  write_varint(buf, arr.length())
  for item in arr {
    writer(buf, item)
  }
}

///|
pub fn[T : Eq + Hash, U] read_map(
  buf : &@buffer.Buffer,
  key_reader : (&@buffer.Buffer) -> T raise,
  value_reader : (&@buffer.Buffer) -> U raise,
) -> Map[T, U] raise {
  let length = read_varint(buf)
  if length < 0 {
    raise fail("Map length is negative")
  }
  let map = Map::new()
  for i = 0; i < length; i = i + 1 {
    let key = key_reader(buf)
    let value = value_reader(buf)
    map.set(key, value)
  }
  map
}

///|
pub fn[T : Eq + Hash, U] write_map(
  buf : &@buffer.Buffer,
  map : Map[T, U],
  key_writer : (&@buffer.Buffer, T) -> Unit,
  value_writer : (&@buffer.Buffer, U) -> Unit,
) -> Unit {
  write_varint(buf, map.size())
  map.each((key, value) => {
    key_writer(buf, key)
    value_writer(buf, value)
  })
}

///|
/// Read an optional value from the buffer.
pub fn[T] read_optional(
  buf : &@buffer.Buffer,
  reader : (&@buffer.Buffer) -> T raise,
) -> T? raise {
  let present = read_bool(buf)
  if present {
    Some(reader(buf))
  } else {
    None
  }
}

///|
/// Write an optional value to the buffer.
pub fn[T] write_optional(
  buf : &@buffer.Buffer,
  value : T?,
  writer : (&@buffer.Buffer, T) -> Unit,
) -> Unit {
  match value {
    None => write_bool(buf, false)
    Some(v) => {
      write_bool(buf, true)
      writer(buf, v)
    }
  }
}

///|
/// Read a UUID (16 bytes) from the buffer.
pub fn read_uuid(buf : &@buffer.Buffer) -> @uuid.UUID raise {
  let bytes = buf.read_bytes(16).unwrap_or(Bytes::make(0, 0))
  @uuid.from_bytes(bytes)
}

///|
/// Write a UUID (16 bytes) to the buffer.
pub fn write_uuid(buf : &@buffer.Buffer, uuid : @uuid.UUID) -> Unit {
  let bytes = uuid.to_bytes()
  buf.write_bytes(bytes)
}

/// below are NOT finished yet

// ///|
// /// Read an unsigned short (2 bytes) from the buffer.
// pub fn read_ushort(buf : &@buffer.Buffer) -> Int {
//   let byte1 = buf.read_byte().unwrap_or(0).to_int()
//   let byte2 = buf.read_byte().unwrap_or(0).to_int()
//   (byte1 << 8) | byte2
// }

// ///|
// /// Write an unsigned short (2 bytes) to the buffer.
// pub fn write_ushort(buf : &@buffer.Buffer, value : Int) -> Unit {
//   buf.write_byte((value >> 8).to_byte())
//   buf.write_byte(value.to_byte())
// }

// ///|
// /// Read a signed short (2 bytes) from the buffer.
// pub fn read_short(buf : &@buffer.Buffer) -> Int {
//   let unsigned = read_ushort(buf)
//   if unsigned >= 0x8000 {
//     unsigned - 0x10000
//   } else {
//     unsigned
//   }
// }

// ///|
// /// Write a signed short (2 bytes) to the buffer.
// pub fn write_short(buf : &@buffer.Buffer, value : Int) -> Unit {
//   let unsigned = if value < 0 { value + 0x10000 } else { value }
//   write_ushort(buf, unsigned)
// }

// ///|
// /// Read an unsigned int (4 bytes) from the buffer.
// pub fn read_uint(buf : &@buffer.Buffer) -> Int64 {
//   let byte1 = buf.read_byte().unwrap_or(0).to_int64()
//   let byte2 = buf.read_byte().unwrap_or(0).to_int64()
//   let byte3 = buf.read_byte().unwrap_or(0).to_int64()
//   let byte4 = buf.read_byte().unwrap_or(0).to_int64()
//   (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4
// }

// ///|
// /// Write an unsigned int (4 bytes) to the buffer.
// pub fn write_uint(buf : &@buffer.Buffer, value : Int64) -> Unit {
//   buf.write_byte((value >> 24).to_byte())
//   buf.write_byte((value >> 16).to_byte())
//   buf.write_byte((value >> 8).to_byte())
//   buf.write_byte(value.to_byte())
// }

// ///|
// /// Read a signed int (4 bytes) from the buffer.
// pub fn read_int(buf : &@buffer.Buffer) -> Int {
//   let byte1 = buf.read_byte().unwrap_or(0).to_int()
//   let byte2 = buf.read_byte().unwrap_or(0).to_int()
//   let byte3 = buf.read_byte().unwrap_or(0).to_int()
//   let byte4 = buf.read_byte().unwrap_or(0).to_int()
//   (byte1 << 24) | (byte2 << 16) | (byte3 << 8) | byte4
// }

// ///|
// /// Write a signed int (4 bytes) to the buffer.
// pub fn write_int(buf : &@buffer.Buffer, value : Int) -> Unit {
//   buf.write_byte((value >> 24).to_byte())
//   buf.write_byte((value >> 16).to_byte())
//   buf.write_byte((value >> 8).to_byte())
//   buf.write_byte(value.to_byte())
// }

// ///|
// /// Read a long (8 bytes) from the buffer.
// pub fn read_long(buf : &@buffer.Buffer) -> Int64 {
//   let mut result : Int64 = 0L
//   for i = 0; i < 8; i = i + 1 {
//     let byte_val = buf.read_byte().unwrap_or(0).to_int64()
//     result = (result << 8) | byte_val
//   }
//   result
// }

// ///|
// /// Write a long (8 bytes) to the buffer.
// pub fn write_long(buf : &@buffer.Buffer, value : Int64) -> Unit {
//   for i = 7; i >= 0; i = i - 1 {
//     buf.write_byte((value >> (i * 8)).to_byte())
//   }
// }

// ///|
// /// Read a float (4 bytes) from the buffer.
// pub fn read_float(buf : &@buffer.Buffer) -> Float {
//   let _int_value = read_int(buf)
//   // TODO: Implement proper float conversion
//   0.0
// }

// ///|
// /// Write a float (4 bytes) to the buffer.
// pub fn write_float(buf : &@buffer.Buffer, _value : Float) -> Unit {
//   // TODO: Implement proper float conversion
//   write_int(buf, 0)
// }

// ///|
// /// Read a double (8 bytes) from the buffer.
// pub fn read_double(buf : &@buffer.Buffer) -> Double {
//   let _long_value = read_long(buf)
//   // TODO: Implement proper double conversion
//   0.0
// }

// ///|
// /// Write a double (8 bytes) to the buffer.
// pub fn write_double(buf : &@buffer.Buffer, _value : Double) -> Unit {
//   // TODO: Implement proper double conversion
//   write_long(buf, 0L)
// }

///|
// /// Read NBT data from the buffer.
// pub fn read_nbt(_buf : &@buffer.Buffer) -> @nbt.NBTTag raise {
//   // TODO: Implement NBT reading
//   raise fail("NBT reading not implemented yet")
// }

// ///|
// /// Write NBT data to the buffer.
// pub fn write_nbt(_buf : &@buffer.Buffer, _nbt : @nbt.NBTTag) -> Unit raise {
//   // TODO: Implement NBT writing
//   raise fail("NBT writing not implemented yet")
// }
