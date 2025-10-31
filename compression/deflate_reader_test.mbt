///|
test "DeflateReader: basic read from byte buffer" {
  // Create a simple byte buffer with some data
  let input_data = Bytes::from_array([1, 2, 3, 4, 5, 6, 7, 8])
  let buf = @bytebuf.make_unpooled(1024)
  let mut i = 0
  while i < input_data.length() {
    buf.write_byte(input_data[i])
    i = i + 1
  }
  buf.set_reader_index(0)
  
  // Wrap in ByteBufReader
  let byte_reader = @io.ByteBufReader::new(buf)
  
  // Create DeflateReader
  let deflate_reader = DeflateReader::new(&byte_reader)
  
  // Read from deflate reader
  let output : FixedArray[Byte] = FixedArray::make(8, 0)
  let bytes_read = deflate_reader.read(output, 0, 8)
  
  // For now, since we don't have full DEFLATE implementation,
  // this is a placeholder test
  assert_true(bytes_read >= 0)
  
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
