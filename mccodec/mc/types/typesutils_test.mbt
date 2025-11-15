///|
test "read_varint - basic functionality" {
  // Test reading valid varint values
  let buf = @buffer.HeapByteBuf::new(1)

  // Write varint 0 (single byte: 0x00)
  buf.write_byte(0x00)
  let value = read_varint(buf)
  inspect(value, content="0")

  // Clear buffer and test varint 127 (single byte: 0x7F)
  buf.clear()
  buf.write_byte(0x7F)
  let value2 = read_varint(buf)
  inspect(value2, content="127")

  // Clear buffer and test varint 128 (two bytes: 0x80 0x01)
  buf.clear()
  buf.write_byte(0x80)
  buf.write_byte(0x01)
  let value3 = read_varint(buf)
  inspect(value3, content="128")
}

///|
test "read_varint - multi-byte values" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Test varint 255 (two bytes: 0xFF 0x01)
  buf.write_byte(0xFF)
  buf.write_byte(0x01)
  let value = read_varint(buf)
  inspect(value, content="255")

  // Test varint 16383 (two bytes: 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value2 = read_varint(buf)
  inspect(value2, content="16383")

  // Test varint 2097151 (three bytes: 0xFF 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value3 = read_varint(buf)
  inspect(value3, content="2097151")
}

///|
test "read_varint - error on oversized varint" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Write 5 bytes with continue bit set (should exceed 32-bit limit)
  buf.write_byte(0x80) // continue bit set
  buf.write_byte(0x80) // continue bit set  
  buf.write_byte(0x80) // continue bit set
  buf.write_byte(0x80) // continue bit set
  buf.write_byte(0x80) // continue bit set (this exceeds position >= 32)
  try {
    let _ = read_varint(buf)

  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}

///|
test "read_varlong - basic functionality" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Test reading varlong 0 (single byte: 0x00)
  buf.write_byte(0x00)
  let value = read_varlong(buf)
  inspect(value, content="0")

  // Clear buffer and test varlong 127 (single byte: 0x7F)
  buf.clear()
  buf.write_byte(0x7F)
  let value2 = read_varlong(buf)
  inspect(value2, content="127")
}

///|
test "read_varlong - multi-byte values" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Test varlong 128 (two bytes: 0x80 0x01)
  buf.write_byte(0x80)
  buf.write_byte(0x01)
  let value = read_varlong(buf)
  inspect(value, content="128")

  // Test varlong 16383 (two bytes: 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value2 = read_varlong(buf)
  inspect(value2, content="16383")

  // Test varlong 2097151 (three bytes: 0xFF 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value3 = read_varlong(buf)
  inspect(value3, content="2097151")

  // Test varlong 268435455 (four bytes: 0xFF 0xFF 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value4 = read_varlong(buf)
  inspect(value4, content="268435455")

  // Test varlong 34359738367 (five bytes: 0xFF 0xFF 0xFF 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value5 = read_varlong(buf)
  inspect(value5, content="34359738367")
}

///|
test "read_varlong - error on oversized varlong" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Write 10 bytes with continue bit set (should exceed 64-bit limit)
  for i = 0; i < 10; i = i + 1 {
    buf.write_byte(0x80) // continue bit set
  }
  try {
    let _ = read_varlong(buf)

  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}

///|
test "read_string - basic functionality" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Test empty string (length 0)
  buf.write_byte(0x00) // varint length = 0
  let empty_str = read_string(buf)
  inspect(empty_str, content="")

  // Test simple ASCII string "hello"
  buf.clear()
  buf.write_byte(0x05) // varint length = 5
  let arr = @encoding/utf8.encode("hello").to_fixedarray()
  buf.write(arr, 0, arr.length()) |> ignore
  let hello_str = read_string(buf)
  inspect(hello_str, content="hello")
}

///|
test "read_string - longer strings" {
  let buf = @buffer.HeapByteBuf::new(1)
  let test_string = "Hello, World! This is a test string."
  let test_bytes = @encoding/utf8.encode(test_string)

  // Write length as varint
  buf.write_byte(test_bytes.length().to_byte())
  let arr = test_bytes.to_fixedarray()
  buf.write(arr, 0, arr.length()) |> ignore
  let result = read_string(buf)
  inspect(result, content="Hello, World! This is a test string.")
}

///|
test "read_string - error on negative length" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Write a negative length (simulate by writing 0xFF, which is -1 as a signed byte)
  buf.write_byte(0xFF) // varint length = -1
  try {
    let _ = read_string(buf)

  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}

///|
test "read_string - insufficient bytes error" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Write length 5 but only provide 2 bytes
  buf.write_byte(0x05) // varint length = 5
  let arr = @encoding/utf8.encode("ab").to_fixedarray()
  buf.write(arr, 0, arr.length()) |> ignore
  try {
    let _ = read_string(buf)

  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}

///|
test "write_varint - basic functionality" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Test writing varint 0 (should be single byte: 0x00)
  write_varint(buf, 0)
  let byte1 = buf.read_byte()
  assert_eq(byte1, 0)

  // Test writing varint 127 (should be single byte: 0x7F)
  buf.clear()
  write_varint(buf, 127)
  let byte2 = buf.read_byte()
  assert_eq(byte2, 127)

  // Test writing varint 128 (should be two bytes: 0x80 0x01)
  buf.clear()
  write_varint(buf, 128)
  let byte3 = buf.read_byte()
  let byte4 = buf.read_byte()
  assert_eq((byte3, byte4), (128, 1))
}

///|
test "write_string - basic functionality" {
  let buf = @buffer.HeapByteBuf::new(1)

  // Test writing empty string
  write_string(buf, "")
  let length1 = buf.read_byte() // should be 0
  assert_eq(length1, 0)

  // Test writing "hello"
  buf.clear()
  write_string(buf, "hello")
  let length2 = buf.read_byte() // should be 5
  assert_eq(length2, 5)
  let _bytes : FixedArray[Byte] = FixedArray::make(5, 0)
  buf.read(_bytes, 0, 5) |> ignore
  let bytes = _bytes.unsafe_reinterpret_as_bytes()
  let decoded = @encoding/utf8.decode(bytes)
  assert_eq(decoded, "hello")
}

///|
test "read_write_roundtrip - varint" {
  let buf = @buffer.HeapByteBuf::new(1)
  let test_values = [0, 1, 127, 128, 255, 16383, 16384, 2097151, 2097152]
  for value in test_values {
    buf.clear()
    write_varint(buf, value)
    let result = read_varint(buf)
    assert_eq(result, value)
  }
}

///|
test "read_write_roundtrip - varlong" {
  let buf = @buffer.HeapByteBuf::new(1)
  let test_values = [
    0L, 1L, 127L, 128L, 255L, 16383L, 16384L, 2097151L, 34359738367L,
  ]
  for value in test_values {
    buf.clear()
    write_varlong(buf, value)
    let result = read_varlong(buf)
    assert_eq(result, value)
  }
}

///|
test "read_write_roundtrip - string" {
  let buf = @buffer.HeapByteBuf::new(1)
  let test_strings = ["", "hello", "Hello, World!", "Unicode: 你好世界"]
  for str in test_strings {
    buf.clear()
    write_string(buf, str)
    let result = read_string(buf)
    assert_eq(result, str)
  }
}
