///|
test "read_varint - basic functionality" {
  // Test reading valid varint values
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Write varint 0 (single byte: 0x00)
  buf.write_byte(0x00)
  let value = buf.read_varint()
  assert_eq(value, 0)

  // Clear buffer and test varint 127 (single byte: 0x7F)
  buf.clear()
  buf.write_byte(0x7F)
  let value2 = buf.read_varint()
  assert_eq(value2, 127)

  // Clear buffer and test varint 128 (two bytes: 0x80 0x01)
  buf.clear()
  buf.write_byte(0x80)
  buf.write_byte(0x01)
  let value3 = buf.read_varint()
  assert_eq(value3, 128)
}

///|
test "read_varint - multi-byte values" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Test varint 255 (two bytes: 0xFF 0x01)
  buf.write_byte(0xFF)
  buf.write_byte(0x01)
  let value = buf.read_varint()
  assert_eq(value, 255)

  // Test varint 16383 (two bytes: 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value2 = buf.read_varint()
  assert_eq(value2, 16383)

  // Test varint 2097151 (three bytes: 0xFF 0xFF 0x7F)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value = buf.read_varint()
  assert_eq(value, 2097151)
}

///|
test "read_varint - error on oversized varint" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Write 5 bytes with continue bit set (should exceed 32-bit limit)
  buf.write_byte(0x80) // continue bit set
  buf.write_byte(0x80) // continue bit set  
  buf.write_byte(0x80) // continue bit set
  buf.write_byte(0x80) // continue bit set
  buf.write_byte(0x80) // continue bit set (this exceeds position >= 32)

  try {
    let _ = buf.read_varint()
  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}

///|
test "read_varlong - basic functionality" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Test reading varlong 0 (single byte: 0x00)
  buf.write_byte(0x00)
  let value = buf.read_varlong()
  assert_eq(value, 0)

  // Clear buffer and test varlong 127 (single byte: 0x7F)
  buf.clear()
  buf.write_byte(0x7F)
  let value2 = buf.read_varlong()
  assert_eq(value2, 127)
}

///|
test "read_varlong - multi-byte values" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Test varlong 128 (two bytes: 0x80 0x01)
  buf.write_byte(0x80)
  buf.write_byte(0x01)
  let value = buf.read_varlong()
  assert_eq(value, 128)

  // Test varlong 16383 (two bytes: 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value2 = buf.read_varlong()
  assert_eq(value2, 16383)

  // Test varlong 2097151 (three bytes: 0xFF 0xFF 0x7F)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value = buf.read_varlong()
  assert_eq(value, 2097151)

  // Test varlong 268435455 (four bytes: 0xFF 0xFF 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value2 = buf.read_varlong()
  assert_eq(value2, 268435455)
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Test varlong 2097151 (three bytes: 0xFF 0xFF 0x7F)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value = buf.read_varlong()
  assert_eq(value, 2097151)

  // Test varlong 34359738367 (five bytes: 0xFF 0xFF 0xFF 0xFF 0x7F)
  buf.clear()
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0xFF)
  buf.write_byte(0x7F)
  let value2 = buf.read_varlong()
  assert_eq(value2, 34359738367)
}

///|
test "read_varlong - error on oversized varlong" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Write 10 bytes with continue bit set (should exceed 64-bit limit)
  for i = 0; i < 10; i = i + 1 {
    buf.write_byte(0x80) // continue bit set
  }

  try {
    let _ = buf.read_varlong()
  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}

///|
test "read_string - basic functionality" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Test empty string (length 0)
  buf.write_byte(0x00) // varint length = 0
  let empty_str = buf.read_string()
  assert_eq(empty_str, "")

  // Test simple ASCII string "hello"
  buf.clear()
  buf.write_byte(0x05) // varint length = 5
  buf.write_bytes(@encoding/utf8.encode("hello"))
  let hello_str = buf.read_string()
  assert_eq(hello_str, "hello")
}

///|
test "read_string - longer strings" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)
  let test_string = "Hello, World! This is a test string."
  let test_bytes = @encoding/utf8.encode(test_string)

  // Write length as varint
  buf.write_byte(test_bytes.length().to_byte())
  buf.write_bytes(test_bytes)
  let result = buf.read_string()
  assert_eq(result, test_string)
}

///|
test "read_string - error on negative length" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Write a negative length (simulate by writing 0xFF, which is -1 as a signed byte)
  buf.write_byte(0xFF) // varint length = -1

  try {
    let _ = buf.read_string()
  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}

///|
test "read_string - insufficient bytes error" {
  let buf : &FriendlyByteBuf = @bytebuf.make_unpooled(1)

  // Write length 5 but only provide 2 bytes
  buf.write_byte(0x05) // varint length = 5
  buf.write_bytes(@encoding/utf8.encode("ab")) // only 2 bytes

  try {
    let _ = buf.read_string()
  } catch {
    _ => assert_true(true)
  } noraise {
    _ => assert_true(false) // Should not reach here
  }
}
