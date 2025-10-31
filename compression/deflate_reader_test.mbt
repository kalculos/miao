///|
test "DeflateReader: decode stored block" {
  // Create a DEFLATE stored block containing [1, 2, 3, 4, 5]
  // Format: BFINAL=1, BTYPE=00, align, LEN=5, NLEN=0xFFFA, data
  let compressed = Bytes::from_array([
    0b00000101, // BFINAL=1, BTYPE=00, align (5 zero bits padding)
    5, 0,       // LEN = 5 (little-endian)
    250, 255,   // NLEN = 0xFFFA = ~5 (little-endian)
    1, 2, 3, 4, 5  // data
  ])
  
  let buf = @bytebuf.make_unpooled(1024)
  let mut i = 0
  while i < compressed.length() {
    buf.write_byte(compressed[i])
    i = i + 1
  }
  buf.set_reader_index(0)
  
  // Wrap in ByteBufReader
  let byte_reader = @io.ByteBufReader::new(buf)
  
  // Create DeflateReader
  let deflate_reader = DeflateReader::new(&byte_reader)
  
  // Read decompressed data
  let output : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = deflate_reader.read(output, 0, 10)
  
  // Verify we got the expected data
  assert_eq(bytes_read, 5)
  assert_eq(output[0], 1)
  assert_eq(output[1], 2)
  assert_eq(output[2], 3)
  assert_eq(output[3], 4)
  assert_eq(output[4], 5)
  
  deflate_reader.close()
}

///|
test "DeflateReader: read returns 0 when closed" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_reader = @io.ByteBufReader::new(buf)
  let deflate_reader = DeflateReader::new(&byte_reader)
  
  deflate_reader.close()
  
  let output : FixedArray[Byte] = FixedArray::make(8, 0)
  let bytes_read = deflate_reader.read(output, 0, 8)
  
  assert_eq(bytes_read, 0)
}

///|
test "DeflateReader: is_closed returns correct state" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_reader = @io.ByteBufReader::new(buf)
  let deflate_reader = DeflateReader::new(&byte_reader)
  
  assert_false(deflate_reader.is_closed())
  
  deflate_reader.close()
  
  assert_true(deflate_reader.is_closed())
}
