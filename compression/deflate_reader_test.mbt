///|
async test "DeflateReader: decode stored block" {
  // BFINAL=1, BTYPE=00, align, LEN=5, NLEN=~5, data
  let compressed = Bytes::from_array([
    0b00000001, // BFINAL=1, BTYPE=00, padding bits = 0
     5, 0, // LEN = 5
     250, 255, // NLEN = ~5
     1, 2, 3, 4, 5,
  ])
  let buf = @buffer.HeapByteBuf::new(1024)
  let mut i = 0
  while i < compressed.length() {
    buf.write_byte(compressed[i])
    i = i + 1
  }
  // buf.clear()

  let byte_reader = @io.ByteBufReader::new(buf)
  let deflate_reader = DeflateReader::new(byte_reader)
  let output : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = deflate_reader.read(output, 0, 10)
  assert_eq(bytes_read, 5)
  assert_eq(output[0], 1)
  assert_eq(output[1], 2)
  assert_eq(output[2], 3)
  assert_eq(output[3], 4)
  assert_eq(output[4], 5)
  deflate_reader.close()
}

///|
async test "DeflateReader: read returns 0 when closed" {
  let buf = @buffer.HeapByteBuf::new(1024)
  let byte_reader = @io.ByteBufReader::new(buf)
  let deflate_reader = DeflateReader::new(byte_reader)
  deflate_reader.close()
  let output : FixedArray[Byte] = FixedArray::make(8, 0)
  let bytes_read = deflate_reader.read(output, 0, 8)
  assert_eq(bytes_read, 0)
}

///|
async test "DeflateReader: is_closed returns correct state" {
  let buf = @buffer.HeapByteBuf::new(1024)
  let byte_reader = @io.ByteBufReader::new(buf)
  let deflate_reader = DeflateReader::new(byte_reader)
  assert_false(deflate_reader.is_closed())
  deflate_reader.close()
  assert_true(deflate_reader.is_closed())
}
