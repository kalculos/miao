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
    byte = buf.read_byte()
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
    byte = buf.read_byte()
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
pub fn read_bool(buf : &@buffer.Buffer) -> Bool raise {
  let byte_val = buf.read_byte()
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
  let bytes = buf.read_bytes(length)
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
  let arr = bytes_to_array(bytes)
  guard buf.write(arr, 0, arr.length()) == arr.length()
}

///|
fn bytes_to_array(b : Bytes) -> FixedArray[Byte] = "%identity"

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
  write_varint(buf, map.length())
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
  let bytes = buf.read_bytes(16)
  @uuid.from_bytes(bytes)
}

///|
/// Write a UUID (16 bytes) to the buffer.
pub fn write_uuid(buf : &@buffer.Buffer, uuid : @uuid.UUID) -> Unit {
  let bytes = uuid.to_bytes()
  let arr = bytes_to_array(bytes)
  guard buf.write(arr, 0, arr.length()) == arr.length()
}

///|
pub fn read_nbt(buf : &@buffer.Buffer) -> @nbt.NBTTag raise {
  let safe_buf = @safenbt.read_nbt_buf(buf)
  @bnbt.parse_uncompressed(safe_buf.read_bytes(safe_buf.readable_bytes()))
}

///|
pub fn write_nbt(buf : &@buffer.Buffer, nbt : @nbt.NBTTag) -> Unit {
  let core_buf = @moonbitlang/core/buffer.new()
  @bnbt.write_uncompressed(nbt, core_buf) catch {
    e => abort(e.to_string()) // TODO: proper error handling, M2
  }
  let arr = bytes_to_array(core_buf.to_bytes())
  guard buf.write(arr, 0, arr.length()) == arr.length()
}
