///|
/// Test coverage for io module
/// 
/// NOTE: The io module defines async traits (Reader and Writer) with async methods.
/// Due to a compiler limitation (v0.6.31) with the `%async.run` intrinsic causing
/// Internal Compiler Error (ICE), we cannot directly test async trait method calls
/// in the test suite. The tests below verify:
/// - Object construction and initialization
/// - Type correctness
/// - Basic structure and composition
///
/// The actual async functionality (read/write operations) is tested through
/// integration tests in other modules that use io components.

///| Tests for ByteBufReader and ByteBufWriter
test "ByteBufReader creation" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  // Reader is created successfully - async methods cannot be tested due to compiler limitation
  inspect(buf.readable_bytes(), content="11")
}

test "ByteBufWriter creation" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  // Writer is created successfully
  inspect(buf.writable_bytes(), content="100")
}

test "ByteBufReader and ByteBufWriter composition" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"test data")
  let dst_buf = @buffer.HeapByteBuf::new(50)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  // Both created successfully for use in async contexts
  inspect(src_buf.readable_bytes(), content="9")
  inspect(dst_buf.writable_bytes(), content="50")
}

///| Tests for DiscardWriter and EmptyClosedReader
test "DiscardWriter creation" {
  let writer = DiscardWriter::new()
  // DiscardWriter created - it should accept all writes (tested in integration)
}

test "EmptyClosedReader creation" {
  let reader = EmptyClosedReader::new()
  // EmptyClosedReader created - it should always return 0 bytes (tested in integration)
}

///| Tests for LimitReader and LimitedWriter
test "LimitReader creation with limit" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 5)
  // Limited reader created with 5 byte limit
  inspect(buf.readable_bytes(), content="11")
}

test "LimitReader with zero limit" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
  let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 0)
  // Limited reader with zero limit created
}

test "LimitedWriter creation with limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(base_writer as &Writer, 10)
  // Limited writer created with 10 byte limit
  inspect(buf.writable_bytes(), content="100")
}

test "LimitedWriter with zero limit" {
  let buf = @buffer.HeapByteBuf::new(50)
  let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(base_writer as &Writer, 0)
  // Limited writer with zero limit created
}

///| Tests for TeeReader and DuplexWriter
test "TeeReader creation" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  // TeeReader created - should copy data to writer when reading
  inspect(src_buf.readable_bytes(), content="5")
  inspect(dst_buf.writable_bytes(), content="10")
}

test "DuplexWriter creation" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  // DuplexWriter created - should write to both writers
  inspect(buf1.writable_bytes(), content="10")
  inspect(buf2.writable_bytes(), content="10")
}

test "DuplexWriter with different capacity buffers" {
  let buf1 = @buffer.HeapByteBuf::new(5)
  let buf2 = @buffer.HeapByteBuf::new(100)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  // DuplexWriter with different capacities - should return min bytes written
  inspect(buf1.writable_bytes(), content="5")
  inspect(buf2.writable_bytes(), content="100")
}

///| Tests for chaining and composition
test "Chained readers - TeeReader with LimitReader" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let dst_buf = @buffer.HeapByteBuf::new(20)
  let base_reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 5)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(limited as &Reader, writer as &Writer)
  // Chained reader created: TeeReader -> LimitReader -> ByteBufReader
}

test "Chained writers - DuplexWriter with LimitedWriter" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let base_writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let limited1 = LimitedWriter::new(base_writer1 as &Writer, 5)
  let base_writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(limited1 as &Writer, base_writer2 as &Writer)
  // Chained writer created: DuplexWriter -> (LimitedWriter, ByteBufWriter)
}

test "Multiple TeeReaders for logging/debugging pattern" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"data")
  let log1_buf = @buffer.HeapByteBuf::new(10)
  let log2_buf = @buffer.HeapByteBuf::new(10)
  
  let base_reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let log1_writer = ByteBufWriter::new(log1_buf as &@buffer.Buffer)
  let tee1 = TeeReader::new(base_reader as &Reader, log1_writer as &Writer)
  let log2_writer = ByteBufWriter::new(log2_buf as &@buffer.Buffer)
  let tee2 = TeeReader::new(tee1 as &Reader, log2_writer as &Writer)
  // Multiple tee readers for multi-destination logging
}

test "DiscardWriter in DuplexWriter for monitoring" {
  let buf = @buffer.HeapByteBuf::new(10)
  let real_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let discard_writer = DiscardWriter::new()
  let duplex = DuplexWriter::new(real_writer as &Writer, discard_writer as &Writer)
  // DuplexWriter with one discard for testing/monitoring without side effects
}

test "EmptyClosedReader as default/placeholder" {
  let empty = EmptyClosedReader::new()
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(empty as &Reader, writer as &Writer)
  // EmptyClosedReader as placeholder in TeeReader
}

///| Buffer size edge cases
test "Very large limit on LimitReader" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"small")
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 999999999)
  // Limit larger than available data
  inspect(buf.readable_bytes(), content="5")
}

test "Very small buffer with normal limit" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"x")
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 100)
  // Small buffer with large limit
  inspect(buf.readable_bytes(), content="1")
}
