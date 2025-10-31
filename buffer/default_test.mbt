///|
/// Tests for integer read operations (big-endian)
test "read_int reads 32-bit integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0x12)
  buf.write_byte(0x34)
  buf.write_byte(0x56)
  buf.write_byte(0x78)
  let value = (buf as &ByteSlice).read_int()
  inspect(value, content="305419896") // 0x12345678
}

///|
test "read_int16 reads 16-bit integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0x12)
  buf.write_byte(0x34)
  let value = (buf as &ByteSlice).read_int16()
  inspect(value, content="4660") // 0x1234
}

///|
test "read_int64 reads 64-bit integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0x12)
  buf.write_byte(0x34)
  buf.write_byte(0x56)
  buf.write_byte(0x78)
  buf.write_byte(0x9A)
  buf.write_byte(0xBC)
  buf.write_byte(0xDE)
  buf.write_byte(0xF0)
  let value = (buf as &ByteSlice).read_int64()
  inspect(value, content="1311768467463790320") // 0x123456789ABCDEF0
}

///|
/// Tests for integer read operations (little-endian)
test "read_int_le reads 32-bit integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0x78)
  buf.write_byte(0x56)
  buf.write_byte(0x34)
  buf.write_byte(0x12)
  let value = (buf as &ByteSlice).read_int_le()
  inspect(value, content="305419896") // 0x12345678
}

///|
test "read_int16_le reads 16-bit integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0x34)
  buf.write_byte(0x12)
  let value = (buf as &ByteSlice).read_int16_le()
  inspect(value, content="4660") // 0x1234
}

///|
test "read_int64_le reads 64-bit integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0xF0)
  buf.write_byte(0xDE)
  buf.write_byte(0xBC)
  buf.write_byte(0x9A)
  buf.write_byte(0x78)
  buf.write_byte(0x56)
  buf.write_byte(0x34)
  buf.write_byte(0x12)
  let value = (buf as &ByteSlice).read_int64_le()
  inspect(value, content="1311768467463790320") // 0x123456789ABCDEF0
}

///|
/// Tests for unsigned integer read operations (big-endian)
test "read_uint reads 32-bit unsigned integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  let value = (buf as &ByteSlice).read_uint()
  inspect(value, content="4294967295") // 0xFFFFFFFF
}

///|
test "read_uint16 reads 16-bit unsigned integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  let value = (buf as &ByteSlice).read_uint16()
  inspect(value, content="65535") // 0xFFFF
}

///|
test "read_uint64 reads 64-bit unsigned integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  for i = 0; i < 8; i = i + 1 {
    buf.write_byte(0xFF)
  }
  let value = (buf as &ByteSlice).read_uint64()
  inspect(value, content="18446744073709551615") // 0xFFFFFFFFFFFFFFFF
}

///|
/// Tests for unsigned integer read operations (little-endian)
test "read_uint_le reads 32-bit unsigned integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  let value = (buf as &ByteSlice).read_uint_le()
  inspect(value, content="4294967295") // 0xFFFFFFFF
}

///|
test "read_uint16_le reads 16-bit unsigned integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  let value = (buf as &ByteSlice).read_uint16_le()
  inspect(value, content="65535") // 0xFFFF
}

///|
test "read_uint64_le reads 64-bit unsigned integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  for i = 0; i < 8; i = i + 1 {
    buf.write_byte(0xFF)
  }
  let value = (buf as &ByteSlice).read_uint64_le()
  inspect(value, content="18446744073709551615") // 0xFFFFFFFFFFFFFFFF
}

///|
/// Tests for integer write operations (big-endian)
test "write_int writes 32-bit integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_int(0x12345678)
  inspect(buf.read_byte().to_int(), content="18") // 0x12
  inspect(buf.read_byte().to_int(), content="52") // 0x34
  inspect(buf.read_byte().to_int(), content="86") // 0x56
  inspect(buf.read_byte().to_int(), content="120") // 0x78
}

///|
test "write_int16 writes 16-bit integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_int16(0x1234)
  inspect(buf.read_byte().to_int(), content="18") // 0x12
  inspect(buf.read_byte().to_int(), content="52") // 0x34
}

///|
test "write_int64 writes 64-bit integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_int64(0x123456789ABCDEF0L)
  inspect(buf.read_byte().to_int(), content="18") // 0x12
  inspect(buf.read_byte().to_int(), content="52") // 0x34
  inspect(buf.read_byte().to_int(), content="86") // 0x56
  inspect(buf.read_byte().to_int(), content="120") // 0x78
  inspect(buf.read_byte().to_int(), content="154") // 0x9A
  inspect(buf.read_byte().to_int(), content="188") // 0xBC
  inspect(buf.read_byte().to_int(), content="222") // 0xDE
  inspect(buf.read_byte().to_int(), content="240") // 0xF0
}

///|
/// Tests for integer write operations (little-endian)
test "write_int_le writes 32-bit integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_int_le(0x12345678)
  inspect(buf.read_byte().to_int(), content="120") // 0x78
  inspect(buf.read_byte().to_int(), content="86") // 0x56
  inspect(buf.read_byte().to_int(), content="52") // 0x34
  inspect(buf.read_byte().to_int(), content="18") // 0x12
}

///|
test "write_int16_le writes 16-bit integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_int16_le(0x1234)
  inspect(buf.read_byte().to_int(), content="52") // 0x34
  inspect(buf.read_byte().to_int(), content="18") // 0x12
}

///|
test "write_int64_le writes 64-bit integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_int64_le(0x123456789ABCDEF0L)
  inspect(buf.read_byte().to_int(), content="240") // 0xF0
  inspect(buf.read_byte().to_int(), content="222") // 0xDE
  inspect(buf.read_byte().to_int(), content="188") // 0xBC
  inspect(buf.read_byte().to_int(), content="154") // 0x9A
  inspect(buf.read_byte().to_int(), content="120") // 0x78
  inspect(buf.read_byte().to_int(), content="86") // 0x56
  inspect(buf.read_byte().to_int(), content="52") // 0x34
  inspect(buf.read_byte().to_int(), content="18") // 0x12
}

///|
/// Tests for unsigned integer write operations (big-endian)
test "write_uint writes 32-bit unsigned integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_uint(0xFFFFFFFFU)
  for i = 0; i < 4; i = i + 1 {
    inspect(buf.read_byte().to_int(), content="255") // 0xFF
  }
}

///|
test "write_uint16 writes 16-bit unsigned integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_uint16(0xFFFFU.to_uint16())
  inspect(buf.read_byte().to_int(), content="255") // 0xFF
  inspect(buf.read_byte().to_int(), content="255") // 0xFF
}

///|
test "write_uint64 writes 64-bit unsigned integer in big-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_uint64(0xFFFFFFFFFFFFFFFFUL)
  for i = 0; i < 8; i = i + 1 {
    inspect(buf.read_byte().to_int(), content="255") // 0xFF
  }
}

///|
/// Tests for unsigned integer write operations (little-endian)
test "write_uint_le writes 32-bit unsigned integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_uint_le(0xFFFFFFFFU)
  for i = 0; i < 4; i = i + 1 {
    inspect(buf.read_byte().to_int(), content="255") // 0xFF
  }
}

///|
test "write_uint16_le writes 16-bit unsigned integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_uint16_le(0xFFFFU.to_uint16())
  inspect(buf.read_byte().to_int(), content="255") // 0xFF
  inspect(buf.read_byte().to_int(), content="255") // 0xFF
}

///|
test "write_uint64_le writes 64-bit unsigned integer in little-endian" {
  let buf = HeapByteBuf::new(10)
  (buf as &ByteSlice).write_uint64_le(0xFFFFFFFFFFFFFFFFUL)
  for i = 0; i < 8; i = i + 1 {
    inspect(buf.read_byte().to_int(), content="255") // 0xFF
  }
}

///|
/// Tests for float read/write operations
test "write and read float in big-endian" {
  let buf = HeapByteBuf::new(10)
  let original : Float = 3.14159
  (buf as &ByteSlice).write_float(original)
  let read_value = (buf as &ByteSlice).read_float()
  // Compare prefix of string representation to avoid minor float formatting differences
  inspect(read_value.to_string()[0:7], content="3.14159")
}

///|
test "write and read float in little-endian" {
  let buf = HeapByteBuf::new(10)
  let original : Float = 3.14159
  (buf as &ByteSlice).write_float_le(original)
  let read_value = (buf as &ByteSlice).read_float_le()
  inspect(read_value.to_string()[0:7], content="3.14159")
}

///|
/// Tests for double read/write operations
test "write and read double in big-endian" {
  let buf = HeapByteBuf::new(10)
  let original : Double = 2.718281828
  (buf as &ByteSlice).write_double(original)
  let read_value = (buf as &ByteSlice).read_double()
  inspect(read_value.to_string(), content="2.718281828")
}

///|
test "write and read double in little-endian" {
  let buf = HeapByteBuf::new(10)
  let original : Double = 2.718281828
  (buf as &ByteSlice).write_double_le(original)
  let read_value = (buf as &ByteSlice).read_double_le()
  inspect(read_value.to_string(), content="2.718281828")
}

///|
/// Tests for write_array
test "write_array writes array data to buffer" {
  let buf = HeapByteBuf::new(10)
  let arr : FixedArray[Byte] = [10, 20, 30, 40, 50]
  let written = (buf as &ByteSlice).write_array(arr, 0, 5)
  inspect(written, content="5")
  inspect(buf.readable_bytes(), content="5")
  inspect(buf.read_byte().to_int(), content="10")
  inspect(buf.read_byte().to_int(), content="20")
}

///|
test "write_array with offset writes partial array" {
  let buf = HeapByteBuf::new(10)
  let arr : FixedArray[Byte] = [10, 20, 30, 40, 50]
  let written = (buf as &ByteSlice).write_array(arr, 2, 3)
  inspect(written, content="3")
  inspect(buf.readable_bytes(), content="3")
  inspect(buf.read_byte().to_int(), content="30")
  inspect(buf.read_byte().to_int(), content="40")
  inspect(buf.read_byte().to_int(), content="50")
}

///|
/// Tests for read_bytes
test "read_bytes reads specified number of bytes" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(1)
  buf.write_byte(2)
  buf.write_byte(3)
  buf.write_byte(4)
  buf.write_byte(5)
  let bytes = (buf as &ByteSlice).read_bytes(3)
  inspect(bytes.length(), content="3")
  inspect(bytes[0].to_int(), content="1")
  inspect(bytes[1].to_int(), content="2")
  inspect(bytes[2].to_int(), content="3")
  inspect(buf.readable_bytes(), content="2")
}

///|
/// Tests for round-trip operations
test "round-trip int32 operations" {
  let buf = HeapByteBuf::new(10)
  let values = [0, 1, -1, 2147483647, -2147483648]
  for value in values {
    buf.clear()
    (buf as &ByteSlice).write_int(value)
    let read_value = (buf as &ByteSlice).read_int()
    if read_value != value {
      abort("Round-trip failed for value: \{value}")
    }
  }
}

///|
test "round-trip uint64 operations" {
  let buf = HeapByteBuf::new(10)
  let values = [0UL, 1UL, 255UL, 65535UL, 4294967295UL]
  for value in values {
    buf.clear()
    (buf as &ByteSlice).write_uint64(value)
    let read_value = (buf as &ByteSlice).read_uint64()
    if read_value != value {
      abort("Round-trip failed for value: \{value}")
    }
  }
}

///|
test "round-trip mixed operations" {
  let buf = HeapByteBuf::new(100)
  (buf as &ByteSlice).write_int(42)
  (buf as &ByteSlice).write_uint16(1000U.to_uint16())
  (buf as &ByteSlice).write_int64(123456789L)
  let v1 = (buf as &ByteSlice).read_int()
  let v2 = (buf as &ByteSlice).read_uint16()
  let v3 = (buf as &ByteSlice).read_int64()
  inspect(v1, content="42")
  inspect(v2, content="1000")
  inspect(v3, content="123456789")
}

///|
/// Tests for error handling
test "read_bytes raises error when not enough data" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(1)
  buf.write_byte(2)
  let result = try {
    let _ = (buf as &ByteSlice).read_bytes(5)
    false
  } catch {
    _ => true
  }
  inspect(result, content="true")
}

///|
test "read_int raises error when not enough data" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(1)
  buf.write_byte(2)
  let result = try {
    let _ = (buf as &ByteSlice).read_int()
    false
  } catch {
    _ => true
  }
  inspect(result, content="true")
}

///|
/// Tests for edge cases with endianness
test "endianness difference is observable" {
  let buf1 = HeapByteBuf::new(10)
  let buf2 = HeapByteBuf::new(10)
  (buf1 as &ByteSlice).write_int(0x12345678)
  (buf2 as &ByteSlice).write_int_le(0x12345678)

  // Read first byte from each - they should differ
  let b1 = buf1.read_byte()
  let b2 = buf2.read_byte()
  inspect(b1.to_int(), content="18") // 0x12 for big-endian
  inspect(b2.to_int(), content="120") // 0x78 for little-endian
}
