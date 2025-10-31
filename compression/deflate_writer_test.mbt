///|
test "DeflateWriter: basic write to byte buffer" {
  // Create a byte buffer to write to
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)
  
  // Create DeflateWriter
  let deflate_writer = DeflateWriter::new(&byte_writer)
  
  // Write some data
  let input : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let bytes_written = deflate_writer.write(input, 0, 5)
  
  // Should accept all bytes
  assert_eq(bytes_written, 5)
  
  deflate_writer.close()
  
  // Verify something was written to the buffer
  buf.set_reader_index(0)
  assert_true(buf.remaining() > 0)
}

///|
test "DeflateWriter: write returns 0 when closed" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)
  let deflate_writer = DeflateWriter::new(&byte_writer)
  
  deflate_writer.close()
  
  let input : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let bytes_written = deflate_writer.write(input, 0, 5)
  
  assert_eq(bytes_written, 0)
}

///|
test "DeflateWriter: is_closed returns correct state" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)
  let deflate_writer = DeflateWriter::new(&byte_writer)
  
  assert_false(deflate_writer.is_closed())
  
  deflate_writer.close()
  
  assert_true(deflate_writer.is_closed())
}

///|
test "DeflateWriter: multiple writes before close" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)
  let deflate_writer = DeflateWriter::new(&byte_writer)
  
  // Write multiple times
  let input1 : FixedArray[Byte] = [1, 2, 3]
  let input2 : FixedArray[Byte] = [4, 5, 6, 7]
  
  let written1 = deflate_writer.write(input1, 0, 3)
  let written2 = deflate_writer.write(input2, 0, 4)
  
  assert_eq(written1, 3)
  assert_eq(written2, 4)
  
  deflate_writer.close()
  
  // Verify data was written
  buf.set_reader_index(0)
  assert_true(buf.remaining() > 0)
}
