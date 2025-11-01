///|
test "adler32_empty_input_test" {
  let data : Array[Byte] = []
  let result = adler32(data)
  assert_eq(result, 0x00000001)
}

///|
test "adler32_numeric_string_test" {
  let data : Array[Byte] = ['1', '2', '3', '4', '5', '6', '7', '8', '9']
  let result = adler32(data)
  assert_eq(result, 0x091E01DE)
}

///|
test "adler32_repeated_pattern_test" {
  // 1000 bytes of 'A' (0x41)
  let data : Array[Byte] = Array::make(1000, 0x41)
  let result = adler32(data)
  // reference computed value from zlib
  assert_eq(result, 0x890CFDE9)
}

///|
test "adler32_common_cases_test" {
  assert_eq(adler32(['a', 'b', 'c']), 0x024d0127)
  assert_eq(adler32(['A', 'B', 'C']), 0x018d00c7)
  assert_eq(
    adler32(['I', ' ', 'a', 'm', ' ', 'a', ' ', 'C', 'a', 't']),
    0x0f2b02f1,
  )
  assert_eq(
    adler32(['I', ' ', 'a', 'm', ' ', 'a', ' ', 'C', 'a', 't', '.']),
    0x124a031f,
  )
}

///|
test "adler32_edge_bytes_test" {
  assert_eq(adler32([0x00]), 0x00010001)
  assert_eq(adler32([0xFF]), 0x01000100)
  assert_eq(adler32([0x00, 0x00]), 0x00020001)
}
