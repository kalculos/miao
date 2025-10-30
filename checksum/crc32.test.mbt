///|
test "crc32_table_generation_test" {
  let table = generate_crc32_table()

  // the CRC32 table must have 256 entries
  assert_eq(table.length(), 256)

  // check some canonical values
  assert_eq(table[0],   0x00000000)
  assert_eq(table[1],   0x77073096)
  assert_eq(table[2],   0xEE0E612C)
  assert_eq(table[255], 0x2D02EF8D)
}

///|
test "crc32_empty_input_test" {
  let data: Array[Byte] = []
  let result = crc32(data)
  assert_eq(result, 0U)
}

///|
test "crc32_numeric_string_test" {
  // "123456789" → standard CRC32 known result: 0xCBF43926
  let data: Array[Byte] = ['1', '2', '3', '4', '5', '6', '7', '8', '9']
  let result = crc32(data)
  assert_eq(result, 0xCBF43926U)
}

///|
test "crc32_repeated_pattern_test" {
  // 1000 bytes of 'A' (0x41)
  let data: Array[Byte] = Array::make(1000, 0x41)
  let result = crc32(data)
  // reference computed value from zlib
  assert_eq(result, 0x51A02E01U)
}

///|
test "crc32_common_cases_test" {
  assert_eq(crc32(['a', 'b', 'c']), 0x352441C2)
  assert_eq(crc32(['A', 'B', 'C']), 0xA3830348)
  assert_eq(crc32(['I', ' ', 'a', 'm', ' ','a', ' ', 'C', 'a', 't']), 0xAF6A6310)
  assert_eq(crc32(['I', ' ', 'a', 'm', ' ','a', ' ', 'C', 'a', 't', '.']), 0x13CC9845)
}

///|
test "crc32_edge_bytes_test" {
  assert_eq(crc32([0x00]), 0xD202EF8D)
  assert_eq(crc32([0xFF]), 0xFF000000)
  assert_eq(crc32([0x00, 0x00]), 0x41D912FF)
}