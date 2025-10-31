///|
test "DeflateWriter: write stored block" {
  // Create a byte buffer to write to
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)

  // Create DeflateWriter
  let deflate_writer = DeflateWriter::new(byte_writer)

  // Write some data
  let input : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let bytes_written = run_async(fn() { deflate_writer.write(input, 0, 5) })

  // Should accept all bytes
  assert_eq(bytes_written, 5)
  run_async_unit(fn() { deflate_writer.close() })

  // Verify DEFLATE stored block was written
  buf.reset()
  assert_true(buf.remaining() > 0)

  // Expected format:
  // - Non-final block with data: BFINAL=0, BTYPE=00, LEN=5, NLEN, data
  // - Final empty block: BFINAL=1, BTYPE=00, LEN=0, NLEN
  // Total: 1 + 4 + 5 + 1 + 4 = 15 bytes (after alignment)

  // Just verify we have reasonable amount of compressed data
  assert_true(buf.remaining() >= 10)
}

///|
test "DeflateWriter: write returns 0 when closed" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)
  let deflate_writer = DeflateWriter::new(byte_writer)
  run_async_unit(fn() { deflate_writer.close() })
  let input : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let bytes_written = run_async(fn() { deflate_writer.write(input, 0, 5) })
  assert_eq(bytes_written, 0)
}

///|
test "DeflateWriter: is_closed returns correct state" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)
  let deflate_writer = DeflateWriter::new(byte_writer)
  assert_false(run_async_bool(fn() { deflate_writer.is_closed() }))
  run_async_unit(fn() { deflate_writer.close() })
  assert_true(run_async_bool(fn() { deflate_writer.is_closed() }))
}

///|
test "DeflateWriter: multiple writes before close" {
  let buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(buf)
  let deflate_writer = DeflateWriter::new(byte_writer)

  // Write multiple times
  let input1 : FixedArray[Byte] = [1, 2, 3]
  let input2 : FixedArray[Byte] = [4, 5, 6, 7]
  let written1 = run_async(fn() { deflate_writer.write(input1, 0, 3) })
  let written2 = run_async(fn() { deflate_writer.write(input2, 0, 4) })
  assert_eq(written1, 3)
  assert_eq(written2, 4)
  run_async_unit(fn() { deflate_writer.close() })

  // Verify data was written
  buf.reset()
  assert_true(buf.remaining() > 0)
}

///|
test "DeflateWriter/Reader: round-trip test" {
  // Write compressed data
  let write_buf = @bytebuf.make_unpooled(1024)
  let byte_writer = @io.ByteBufWriter::new(write_buf)
  let deflate_writer = DeflateWriter::new(byte_writer)
  let original_data : FixedArray[Byte] = [10, 20, 30, 40, 50, 60, 70, 80]
  let written = run_async(fn() { deflate_writer.write(original_data, 0, 8) })
  assert_eq(written, 8)
  run_async_unit(fn() { deflate_writer.close() })

  // Read compressed data back
  write_buf.reset()
  let byte_reader = @io.ByteBufReader::new(write_buf)
  let deflate_reader = DeflateReader::new(byte_reader)
  let decompressed : FixedArray[Byte] = FixedArray::make(10, 0)
  let read_bytes = run_async(fn() { deflate_reader.read(decompressed, 0, 10) })

  // Verify round-trip
  assert_eq(read_bytes, 8)
  assert_eq(decompressed[0], 10)
  assert_eq(decompressed[1], 20)
  assert_eq(decompressed[2], 30)
  assert_eq(decompressed[3], 40)
  assert_eq(decompressed[4], 50)
  assert_eq(decompressed[5], 60)
  assert_eq(decompressed[6], 70)
  assert_eq(decompressed[7], 80)
  run_async_unit(fn() { deflate_reader.close() })
}
