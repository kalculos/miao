///|
priv struct TestData[T] {
  data : T
  byte_expect : Bytes
}

///|
let uint_data : Array[TestData[UInt]] = [
  TestData::{ data: 0x01020304, byte_expect: [4, 3, 2, 1] },
  TestData::{ data: 0x01020304, byte_expect: [1, 2, 3, 4] },
]

///|
let uint16_data : Array[TestData[UInt16]] = [
  TestData::{ data: 0x0102, byte_expect: [2, 1] },
  TestData::{ data: 0x0102, byte_expect: [1, 2] },
]

///|
let uint64_data : Array[TestData[UInt64]] = [
  TestData::{ data: 0x0102030405060708, byte_expect: [8, 7, 6, 5, 4, 3, 2, 1] },
  TestData::{ data: 0x0102030405060708, byte_expect: [1, 2, 3, 4, 5, 6, 7, 8] },
]

///|
let int_data : Array[TestData[Int]] = [
  TestData::{ data: 0x01020304, byte_expect: [4, 3, 2, 1] },
  TestData::{ data: 0x01020304, byte_expect: [1, 2, 3, 4] },
]

///|
let int16_data : Array[TestData[Int16]] = [
  TestData::{ data: 0x0102, byte_expect: [2, 1] },
  TestData::{ data: 0x0102, byte_expect: [1, 2] },
]

///|
let int64_data : Array[TestData[Int64]] = [
  TestData::{ data: 0x0102030405060708, byte_expect: [8, 7, 6, 5, 4, 3, 2, 1] },
  TestData::{ data: 0x0102030405060708, byte_expect: [1, 2, 3, 4, 5, 6, 7, 8] },
]

///|
test "test default read/write operations" {
  let buf = @buffer.make_unpooled(10)

  // uint_le
  buf.write_uint_le(uint_data[0].data)
  assert_eq(
    buf.to_bytes(),
    uint_data[0].byte_expect,
    msg="write_uint_le failed",
  )
  assert_eq(
    buf.read_uint_le(),
    Some(uint_data[0].data),
    msg="read_uint_le failed",
  )
  buf.clear()
  // uint_be
  assert_true(buf.is_empty(), msg="buf should be empty after clear")
  assert_false(buf.has_remaining(), msg="buf should have no remaining data")
  buf.write_uint(uint_data[1].data)
  assert_true(buf.has_remaining(), msg="buf should have remaining data")
  assert_eq(buf.to_bytes(), uint_data[1].byte_expect, msg="write_uint failed")
  assert_eq(buf.read_uint(), Some(uint_data[1].data), msg="read_uint_be failed")
  buf.clear()

  // uint16_le
  buf.write_uint16_le(uint16_data[0].data)
  assert_eq(
    buf.to_bytes(),
    uint16_data[0].byte_expect,
    msg="write_uint16_le failed",
  )
  assert_eq(
    buf.read_uint16_le(),
    Some(uint16_data[0].data),
    msg="write_uint16_le failed",
  )
  buf.clear()
  // uint16_be
  buf.write_uint16(uint16_data[1].data)
  assert_eq(
    buf.to_bytes(),
    uint16_data[1].byte_expect,
    msg="write_uint16 failed",
  )
  assert_eq(
    buf.read_uint16(),
    Some(uint16_data[1].data),
    msg="write_uint16 failed",
  )
  buf.clear()
  // uint64_le
  buf.write_uint64_le(uint64_data[0].data)
  assert_eq(
    buf.to_bytes(),
    uint64_data[0].byte_expect,
    msg="write_uint64_le failed",
  )
  assert_eq(
    buf.read_uint64_le(),
    Some(uint64_data[0].data),
    msg="write_uint64_le failed",
  )
  buf.clear()
  // uint64_be
  buf.write_uint64(uint64_data[1].data)
  assert_eq(
    buf.to_bytes(),
    uint64_data[1].byte_expect,
    msg="write_uint64 failed",
  )
  assert_eq(
    buf.read_uint64(),
    Some(uint64_data[1].data),
    msg="write_uint64 failed",
  )
  buf.clear()
  // int_le
  buf.write_int_le(int_data[0].data)
  assert_eq(buf.to_bytes(), int_data[0].byte_expect, msg="write_int_le failed")
  assert_eq(
    buf.read_int_le(),
    Some(int_data[0].data),
    msg="write_int_le failed",
  )
  buf.clear()

  // float_le
  buf.write_float_le(int_data[0].data.reinterpret_as_float())
  assert_eq(
    buf.to_bytes(),
    int_data[0].byte_expect,
    msg="write_float_le failed",
  )
  assert_eq(
    buf.read_float_le(),
    Some(int_data[0].data.reinterpret_as_float()),
    msg="write_float_le failed",
  )
  buf.clear()

  // int_be
  buf.write_int(int_data[1].data)
  assert_eq(buf.to_bytes(), int_data[1].byte_expect, msg="write_int failed")
  assert_eq(buf.read_int(), Some(int_data[1].data), msg="write_int failed")
  buf.clear()

  // float_be
  buf.write_float(int_data[1].data.reinterpret_as_float())
  assert_eq(buf.to_bytes(), int_data[1].byte_expect, msg="write_float failed")
  assert_eq(
    buf.read_float(),
    Some(int_data[1].data.reinterpret_as_float()),
    msg="write_float failed",
  )
  buf.clear()

  // int16_le
  buf.write_int16_le(int16_data[0].data)
  assert_eq(
    buf.to_bytes(),
    int16_data[0].byte_expect,
    msg="read_int16_le failed",
  )
  assert_eq(
    buf.read_int16_le(),
    Some(int16_data[0].data),
    msg="read_uint_le failed",
  )
  buf.clear()
  // int16_be
  buf.write_int16(int16_data[1].data)
  assert_eq(buf.to_bytes(), int16_data[1].byte_expect, msg="write_int16 failed")
  assert_eq(
    buf.read_int16(),
    Some(int16_data[1].data),
    msg="write_int16 failed",
  )
  buf.clear()
  // int64_le
  buf.write_int64_le(int64_data[0].data)
  assert_eq(
    buf.to_bytes(),
    int64_data[0].byte_expect,
    msg="write_int64_le failed",
  )
  assert_eq(
    buf.read_int64_le(),
    Some(int64_data[1].data),
    msg="write_int64_le failed",
  )
  buf.clear()

  //double le
  buf.write_double_le(int64_data[0].data.reinterpret_as_double())
  assert_eq(
    buf.to_bytes(),
    int64_data[0].byte_expect,
    msg="write_double_le failed",
  )
  assert_eq(
    buf.read_double_le(),
    Some(int64_data[0].data.reinterpret_as_double()),
    msg="write_double_le failed",
  )
  buf.clear()
  // int64_be
  buf.write_int64(int64_data[1].data)
  assert_eq(buf.to_bytes(), int64_data[1].byte_expect, msg="write_int64 failed")
  assert_eq(
    buf.read_int64(),
    Some(int64_data[1].data),
    msg="write_int64 failed",
  )
  buf.clear()
  //double be
  buf.write_double(int64_data[1].data.reinterpret_as_double())
  assert_eq(buf.to_bytes(), int64_data[1].byte_expect, msg="write_double failed")
  assert_eq(
    buf.read_double(),
    Some(int64_data[1].data.reinterpret_as_double()),
    msg="write_int_le failed",
  )
  buf.clear()
}


///|
test "test write_array method" {
  let buf = @buffer.make_unpooled(10)
  let test_array : FixedArray[Byte] = [1, 2, 3, 4, 5, 6, 7, 8]
  
  // Test normal write_array
  buf.write_array(test_array, 0, 4)
  assert_eq(buf.to_bytes(), [1, 2, 3, 4], msg="write_array failed with offset 0, len 4")
  buf.clear()
  
  // Test write_array with offset
  buf.write_array(test_array, 2, 3)
  assert_eq(buf.to_bytes(), [3, 4, 5], msg="write_array failed with offset 2, len 3")
  buf.clear()
  
  // Test write_array with full array (guard should allow this: 8 > 0 + 8 is false, so it passes)
  buf.write_array(test_array, 0, 8)
  assert_eq(buf.to_bytes(), [1, 2, 3, 4, 5, 6, 7, 8], msg="write_array failed with full array")
  buf.clear()
  
  // Test write_array with single byte
  buf.write_array(test_array, 5, 1)
  assert_eq(buf.to_bytes(), [6], msg="write_array failed with single byte")
  buf.clear()
}

///|
test "test read_bytes_most method" {
  let buf = @buffer.make_unpooled(10)
  let test_data : FixedArray[Byte] = [10, 20, 30, 40, 50]
  
  // Write test data
  buf.write_bytes(Bytes::from_fixedarray(test_data))
  buf.reset() // Reset to read from beginning
  
  // Test read_bytes_most with exact length
  let result1 = buf.read_bytes_most(3)
  assert_eq(result1, [10, 20, 30], msg="read_bytes_most failed with exact length")
  
  // Test read_bytes_most with more than available
  let result2 = buf.read_bytes_most(5)
  assert_eq(result2, [40, 50], msg="read_bytes_most failed with more than available")
  
  // Test read_bytes_most when empty
  let result3 = buf.read_bytes_most(3)
  assert_eq(result3, [], msg="read_bytes_most failed when empty")
  
  // Test read_bytes_most with zero length
  buf.reset()
  let result4 = buf.read_bytes_most(0)
  assert_eq(result4, [], msg="read_bytes_most failed with zero length")
  
  // Test read_bytes_most with large request
  buf.reset()
  let result5 = buf.read_bytes_most(100)
  assert_eq(result5, [10, 20, 30, 40, 50], msg="read_bytes_most failed with large request")
}

///|
test "test read method" {
  let buf = @buffer.make_unpooled(10)
  let test_data : FixedArray[Byte] = [1, 2, 3, 4, 5, 6]
  let dst : FixedArray[Byte] = FixedArray::make(10, 0)
  
  // Write test data
  buf.write_bytes(Bytes::from_fixedarray(test_data))
  buf.reset() // Reset to read from beginning
  
  // Test read with exact length
  let read1 = buf.read(dst, 0, 3)
  assert_eq(read1, 3, msg="read failed to return correct count")
  assert_eq(dst[0], 1, msg="read failed to copy first byte")
  assert_eq(dst[1], 2, msg="read failed to copy second byte")
  assert_eq(dst[2], 3, msg="read failed to copy third byte")
  
  // Test read with offset in destination - should read remaining bytes [4, 5, 6]
  let read2 = buf.read(dst, 3, 3)
  assert_eq(read2, 3, msg="read failed with destination offset")
  assert_eq(dst[3], 4, msg="read failed to copy fourth byte")
  assert_eq(dst[4], 5, msg="read failed to copy fifth byte")
  assert_eq(dst[5], 6, msg="read failed to copy sixth byte")
  
  // Test read when no more data - should return 0 since we're at EOF
  let read3 = buf.read(dst, 6, 3)
  assert_eq(read3, 0, msg="read failed when no more data available")
  
  // Test read when completely empty - new buffer
  let buf2 = @buffer.make_unpooled(5)
  let dst2 : FixedArray[Byte] = FixedArray::make(5, 0)
  let read4 = buf2.read(dst2, 0, 2)
  assert_eq(read4, 0, msg="read failed when completely empty")
  
  // Test read with zero length
  buf.reset()
  let read5 = buf.read(dst, 0, 0)
  assert_eq(read5, 0, msg="read failed with zero length")
  // Test read with large request - should read all available data
  buf.reset()
  let read6 = buf.read(dst, 0, 100)
  assert_eq(read6, -1)
}

///|
test "test write_array edge cases" {
  let buf = @buffer.make_unpooled(10)
  let test_array : FixedArray[Byte] = [1, 2, 3]
  
  // Test write_array with offset at boundary (2 + 1 = 3, which is not > 3)
  buf.write_array(test_array, 2, 1)
  assert_eq(buf.to_bytes(), [3], msg="write_array failed at boundary")
  buf.clear()
  
  // Test write_array with len at boundary (1 + 2 = 3, which is not > 3)
  buf.write_array(test_array, 1, 2)
  assert_eq(buf.to_bytes(), [2, 3], msg="write_array failed with len at boundary")
  buf.clear()
}

///|
test "test read_bytes_most edge cases" {
  let buf = @buffer.make_unpooled(10)
  
  // Test with empty buffer from start
  let result = buf.read_bytes_most(5)
  assert_eq(result, [], msg="read_bytes_most failed with empty buffer")
  
  // Test single byte buffer
  buf.write_byte(42)
  buf.reset()
  let result2 = buf.read_bytes_most(1)
  assert_eq(result2, [42], msg="read_bytes_most failed with single byte")
}

///|
test "test read edge cases" {
  let buf = @buffer.make_unpooled(10)
  let dst : FixedArray[Byte] = FixedArray::make(5, 0)
  
  // Test with empty buffer
  let read1 = buf.read(dst, 0, 5)
  assert_eq(read1, 0, msg="read failed with empty buffer")
  
  // Test with destination offset - ensure we don't go out of bounds
  buf.write_bytes(Bytes::from_fixedarray([1, 2]))
  buf.reset()
  let read2 = buf.read(dst, 3, 2)  // Only 2 bytes available, destination has space
  assert_eq(read2, 2, msg="read failed with destination offset")
  assert_eq(dst[3], 1, msg="read failed to copy first byte at offset")
  assert_eq(dst[4], 2, msg="read failed to copy second byte at offset")
}
