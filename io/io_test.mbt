///|
/// Test coverage for io module

///| `run_async` spawn a new coroutine and execute an async function in it
fn run_async(f : async () -> Unit noraise) -> Unit = "%async.run"

///| Helper to run async code that may raise errors in tests
fn test_async(f : async () -> Unit) -> Unit {
  run_async(fn() {
    try {
      f()
    } catch {
      e => abort("Test failed with error: \{e}")
    }
  })
}

///| Tests for ByteBufReader
test "ByteBufReader read operations" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
    let reader = ByteBufReader::new(buf as &@buffer.Buffer)
    
    // Test basic read
    let dst : FixedArray[Byte] = FixedArray::make(5, 0)
    let bytes_read = reader.read(dst, 0, 5)
    inspect(bytes_read, content="5")
    inspect(dst[0].to_int(), content="104") // 'h'
    inspect(dst[4].to_int(), content="111") // 'o'
    
    // Test partial read (try to read more than buffer size, should only read what's available)
    let dst2 : FixedArray[Byte] = FixedArray::make(10, 0)
    let bytes_read2 = reader.read(dst2, 0, 10)
    inspect(bytes_read2, content="6") // remaining " world"
  })
}

test "ByteBufReader empty and closed states" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::new(10)
    let reader = ByteBufReader::new(buf as &@buffer.Buffer)
    
    // Empty buffer returns 0
    let dst : FixedArray[Byte] = FixedArray::make(5, 0)
    inspect(reader.read(dst, 0, 5), content="0")
    
    // Close and verify
    inspect(reader.is_closed(), content="false")
    reader.close()
    inspect(reader.is_closed(), content="true")
    inspect(reader.available(), content="0")
  })
}

test "ByteBufReader read_all and read_buffer" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
    let reader = ByteBufReader::new(buf as &@buffer.Buffer)
    let result = reader.read_buffer(5)
    inspect(result.readable_bytes(), content="5")
  })
}

test "ByteBufReader read_buffer_to" {
  test_async(fn() {
    let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
    let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
    let dst_buf = @buffer.HeapByteBuf::new(10)
    let bytes_read = reader.read_buffer_to(dst_buf as &@buffer.Buffer)
    inspect(bytes_read, content="5")
    inspect(dst_buf.readable_bytes(), content="5")
  })
}

///| Tests for ByteBufWriter
test "ByteBufWriter write operations" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::new(10)
    let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
    
    let src : FixedArray[Byte] = [104, 101, 108, 108, 111]
    let bytes_written = writer.write(src, 0, 5)
    inspect(bytes_written, content="5")
    inspect(buf.readable_bytes(), content="5")
    
    // Test closed state
    inspect(writer.is_closed(), content="false")
    writer.close()
    inspect(writer.is_closed(), content="true")
  })
}

test "ByteBufWriter capacity limits" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::new(3)
    let src : FixedArray[Byte] = [1, 2, 3]
    ignore(buf.write(src, 0, 3))
    let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
    
    // Full buffer returns 0
    let src2 : FixedArray[Byte] = [4, 5]
    inspect(writer.write(src2, 0, 2), content="0")
  })
}

test "ByteBufWriter write_buffer" {
  test_async(fn() {
    let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
    let dst_buf = @buffer.HeapByteBuf::new(10)
    let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
    let bytes_written = writer.write_buffer(src_buf as &@buffer.Buffer)
    inspect(bytes_written, content="5")
    inspect(dst_buf.readable_bytes(), content="5")
  })
}

///| Tests for DiscardWriter
test "DiscardWriter always accepts writes" {
  test_async(fn() {
    let writer = DiscardWriter::new()
    
    // Always returns requested length
    let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
    inspect(writer.write(data, 0, 5), content="5")
    
    // Large write
    let large_data : FixedArray[Byte] = FixedArray::make(1000, 42)
    inspect(writer.write(large_data, 0, 1000), content="1000")
    
    // Never closed
    inspect(writer.is_closed(), content="false")
    writer.close()
    inspect(writer.is_closed(), content="false")
    
    // Works after "close"
    inspect(writer.write(data, 0, 3), content="3")
  })
}

test "DiscardWriter write_buffer consumes buffer" {
  test_async(fn() {
    let writer = DiscardWriter::new()
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
    let bytes_written = writer.write_buffer(buf as &@buffer.Buffer)
    inspect(bytes_written, content="11")
    inspect(buf.readable_bytes(), content="0")
  })
}

///| Tests for EmptyClosedReader
test "EmptyClosedReader always returns EOF" {
  test_async(fn() {
    let reader = EmptyClosedReader::new()
    
    // Always closed
    inspect(reader.is_closed(), content="true")
    
    // Always returns 0
    let dst : FixedArray[Byte] = FixedArray::make(10, 0)
    inspect(reader.read(dst, 0, 10), content="0")
    inspect(reader.read(dst, 0, 1000), content="0")
    
    // Available is 0
    inspect(reader.available(), content="0")
    
    // read_all returns empty
    let result = reader.read_all()
    inspect(result.readable_bytes(), content="0")
    
    // Close is no-op
    reader.close()
    inspect(reader.is_closed(), content="true")
  })
}

///| Tests for LimitReader
test "LimitReader respects read limit" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
    let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
    let limited = LimitReader::new(base_reader as &Reader, 5)
    
    // Read within limit
    let dst : FixedArray[Byte] = FixedArray::make(10, 0)
    let bytes_read = limited.read(dst, 0, 10)
    inspect(bytes_read, content="5")
    
    // Further reads return 0
    inspect(limited.read(dst, 0, 10), content="0")
  })
}

test "LimitReader multiple reads within limit" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
    let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
    let limited = LimitReader::new(base_reader as &Reader, 10)
    
    let dst : FixedArray[Byte] = FixedArray::make(5, 0)
    inspect(limited.read(dst, 0, 5), content="5")
    inspect(limited.read(dst, 0, 5), content="5")
    inspect(limited.read(dst, 0, 5), content="0")
  })
}

test "LimitReader close and state" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
    let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
    let limited = LimitReader::new(base_reader as &Reader, 5)
    
    inspect(limited.is_closed(), content="false")
    limited.close()
    inspect(base_reader.is_closed(), content="true")
    inspect(limited.is_closed(), content="true")
  })
}

///| Tests for LimitedWriter
test "LimitedWriter respects write limit" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::new(100)
    let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
    let limited = LimitedWriter::new(base_writer as &Writer, 5)
    
    let src : FixedArray[Byte] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    let bytes_written = limited.write(src, 0, 10)
    inspect(bytes_written, content="5")
    
    // Further writes return 0
    inspect(limited.write(src, 0, 10), content="0")
  })
}

test "LimitedWriter multiple writes within limit" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::new(100)
    let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
    let limited = LimitedWriter::new(base_writer as &Writer, 10)
    
    let src : FixedArray[Byte] = [1, 2, 3, 4, 5]
    inspect(limited.write(src, 0, 5), content="5")
    inspect(limited.write(src, 0, 5), content="5")
    inspect(limited.write(src, 0, 5), content="0")
  })
}

test "LimitedWriter close and state" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::new(100)
    let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
    let limited = LimitedWriter::new(base_writer as &Writer, 10)
    
    inspect(limited.is_closed(), content="false")
    limited.close()
    inspect(base_writer.is_closed(), content="true")
    inspect(limited.is_closed(), content="true")
  })
}

///| Tests for TeeReader
test "TeeReader copies data to writer" {
  test_async(fn() {
    let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
    let dst_buf = @buffer.HeapByteBuf::new(10)
    let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
    let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
    let tee = TeeReader::new(reader as &Reader, writer as &Writer)
    
    let data : FixedArray[Byte] = FixedArray::make(5, 0)
    let bytes_read = tee.read(data, 0, 5)
    inspect(bytes_read, content="5")
    inspect(data[0].to_int(), content="104") // 'h'
    inspect(dst_buf.readable_bytes(), content="5")
  })
}

test "TeeReader handles partial writes" {
  test_async(fn() {
    let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
    let dst_buf = @buffer.HeapByteBuf::new(3) // Small buffer
    let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
    let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
    let tee = TeeReader::new(reader as &Reader, writer as &Writer)
    
    let data : FixedArray[Byte] = FixedArray::make(5, 0)
    let bytes_read = tee.read(data, 0, 5)
    inspect(bytes_read, content="5") // Reads 5
    inspect(dst_buf.readable_bytes(), content="3") // Writes only 3
  })
}

test "TeeReader close closes both" {
  test_async(fn() {
    let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
    let dst_buf = @buffer.HeapByteBuf::new(10)
    let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
    let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
    let tee = TeeReader::new(reader as &Reader, writer as &Writer)
    
    tee.close()
    inspect(reader.is_closed(), content="true")
    inspect(writer.is_closed(), content="true")
    inspect(tee.is_closed(), content="true")
  })
}

///| Tests for DuplexWriter
test "DuplexWriter writes to both writers" {
  test_async(fn() {
    let buf1 = @buffer.HeapByteBuf::new(10)
    let buf2 = @buffer.HeapByteBuf::new(10)
    let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
    let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
    let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
    
    let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
    let bytes_written = duplex.write(data, 0, 5)
    inspect(bytes_written, content="5")
    inspect(buf1.readable_bytes(), content="5")
    inspect(buf2.readable_bytes(), content="5")
  })
}

test "DuplexWriter returns minimum written" {
  test_async(fn() {
    let buf1 = @buffer.HeapByteBuf::new(3)
    let buf2 = @buffer.HeapByteBuf::new(10)
    let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
    let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
    let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
    
    let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
    let bytes_written = duplex.write(data, 0, 5)
    inspect(bytes_written, content="3")
  })
}

test "DuplexWriter close closes both" {
  test_async(fn() {
    let buf1 = @buffer.HeapByteBuf::new(10)
    let buf2 = @buffer.HeapByteBuf::new(10)
    let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
    let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
    let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
    
    duplex.close()
    inspect(writer1.is_closed(), content="true")
    inspect(writer2.is_closed(), content="true")
    inspect(duplex.is_closed(), content="true")
  })
}

///| Tests for edge cases
test "LimitReader with zero limit" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
    let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
    let limited = LimitReader::new(base_reader as &Reader, 0)
    
    let dst : FixedArray[Byte] = FixedArray::make(5, 0)
    inspect(limited.read(dst, 0, 5), content="0")
  })
}

test "LimitedWriter with zero limit" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::new(50)
    let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
    let limited = LimitedWriter::new(base_writer as &Writer, 0)
    
    let src : FixedArray[Byte] = [1, 2, 3]
    inspect(limited.write(src, 0, 3), content="0")
  })
}

test "Very large limit on LimitReader" {
  test_async(fn() {
    let buf = @buffer.HeapByteBuf::wrapped_bytes(b"small")
    let reader = ByteBufReader::new(buf as &@buffer.Buffer)
    let limited = LimitReader::new(reader as &Reader, 999999999)
    
    let dst : FixedArray[Byte] = FixedArray::make(10, 0)
    inspect(limited.read(dst, 0, 10), content="5")
  })
}
