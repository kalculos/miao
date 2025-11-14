fn[T] run_async(f : async () -> T) -> T = "%async.run"
fn run_async_unit(f : async () -> Unit) -> Unit = "%async.run"
fn run_async_bool(f : async () -> Bool) -> Bool = "%async.run"


///| Tests for ByteBufReader
test "ByteBufReader read operations" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  
  // Test basic read
  let dst : FixedArray[Byte] = FixedArray::make(5, 0)
  let bytes_read = run_async(fn() { reader.read(dst, 0, 5) })
  inspect(bytes_read, content="5")
  inspect(dst[0].to_int(), content="104") // 'h'
  
  // Test partial read
  let bytes_read2 = run_async(fn() { reader.read(dst, 0, 10) })
  inspect(bytes_read2, content="6") // remaining "world" + space
}

test "ByteBufReader empty and closed states" {
  let buf = @buffer.HeapByteBuf::new(10)
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  
  // Empty buffer returns 0
  let dst : FixedArray[Byte] = FixedArray::make(5, 0)
  inspect(run_async(fn() { reader.read(dst, 0, 5) }), content="0")
  
  // Close and verify
  inspect(run_async_bool(fn() { reader.is_closed() }), content="false")
  run_async_unit(fn() { reader.close() })
  inspect(run_async_bool(fn() { reader.is_closed() }), content="true")
  inspect(run_async(fn() { reader.available() }), content="0")
}

test "ByteBufReader read_all and read_buffer" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let result = run_async(fn() { reader.read_buffer(5) })
  inspect(result.readable_bytes(), content="5")
}

test "ByteBufReader read_buffer_to" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let bytes_read = run_async(fn() { reader.read_buffer_to(dst_buf as &@buffer.Buffer) })
  inspect(bytes_read, content="5")
  inspect(dst_buf.readable_bytes(), content="5")
}

///| Tests for ByteBufWriter
test "ByteBufWriter write operations" {
  let buf = @buffer.HeapByteBuf::new(10)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  
  let src : FixedArray[Byte] = [104, 101, 108, 108, 111]
  let bytes_written = run_async(fn() { writer.write(src, 0, 5) })
  inspect(bytes_written, content="5")
  inspect(buf.readable_bytes(), content="5")
  
  // Test closed state
  inspect(run_async_bool(fn() { writer.is_closed() }), content="false")
  run_async_unit(fn() { writer.close() })
  inspect(run_async_bool(fn() { writer.is_closed() }), content="true")
}

test "ByteBufWriter capacity limits" {
  let buf = @buffer.HeapByteBuf::new(3)
  let src : FixedArray[Byte] = [1, 2, 3]
  ignore(buf.write(src, 0, 3))
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  
  // Full buffer returns 0
  let src2 : FixedArray[Byte] = [4, 5]
  inspect(run_async(fn() { writer.write(src2, 0, 2) }), content="0")
}

test "ByteBufWriter write_buffer" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let bytes_written = run_async(fn() { writer.write_buffer(src_buf as &@buffer.Buffer) })
  inspect(bytes_written, content="5")
  inspect(dst_buf.readable_bytes(), content="5")
}

///| Tests for Reader trait defaults
test "Reader default implementations" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"test data")
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  
  // Test read_all
  let result = run_async(fn() { reader.read_all() })
  inspect(result.readable_bytes(), content="9")
  
  // Test available
  let buf2 = @buffer.HeapByteBuf::wrapped_bytes(b"test")
  let reader2 = ByteBufReader::new(buf2 as &@buffer.Buffer)
  let avail = run_async(fn() { reader2.available() })
  if avail <= 0 {
    abort("Should have data available")
  }
}

///| Tests for DiscardWriter
test "DiscardWriter always accepts writes" {
  let writer = DiscardWriter::new()
  
  // Always returns requested length
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  inspect(run_async(fn() { writer.write(data, 0, 5) }), content="5")
  
  // Large write
  let large_data : FixedArray[Byte] = FixedArray::make(1000, 42)
  inspect(run_async(fn() { writer.write(large_data, 0, 1000) }), content="1000")
  
  // Never closed
  inspect(run_async_bool(fn() { writer.is_closed() }), content="false")
  run_async_unit(fn() { writer.close() })
  inspect(run_async_bool(fn() { writer.is_closed() }), content="false")
  
  // Works after "close"
  inspect(run_async(fn() { writer.write(data, 0, 3) }), content="3")
}

test "DiscardWriter write_buffer consumes buffer" {
  let writer = DiscardWriter::new()
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let bytes_written = run_async(fn() { writer.write_buffer(buf as &@buffer.Buffer) })
  inspect(bytes_written, content="11")
  inspect(buf.readable_bytes(), content="0")
}

///| Tests for EmptyClosedReader
test "EmptyClosedReader always returns EOF" {
  let reader = EmptyClosedReader::new()
  
  // Always closed
  inspect(run_async_bool(fn() { reader.is_closed() }), content="true")
  
  // Always returns 0
  let dst : FixedArray[Byte] = FixedArray::make(10, 0)
  inspect(run_async(fn() { reader.read(dst, 0, 10) }), content="0")
  inspect(run_async(fn() { reader.read(dst, 0, 1000) }), content="0")
  
  // Available is 0
  inspect(run_async(fn() { reader.available() }), content="0")
  
  // read_all returns empty
  let result = run_async(fn() { reader.read_all() })
  inspect(result.readable_bytes(), content="0")
  
  // Close is no-op
  run_async_unit(fn() { reader.close() })
  inspect(run_async_bool(fn() { reader.is_closed() }), content="true")
}

///| Tests for LimitReader
test "LimitReader respects read limit" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 5)
  
  // Read within limit
  let dst : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = run_async(fn() { limited.read(dst, 0, 10) })
  inspect(bytes_read, content="5")
  
  // Further reads return 0
  inspect(run_async(fn() { limited.read(dst, 0, 10) }), content="0")
}

test "LimitReader multiple reads within limit" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 10)
  
  let dst : FixedArray[Byte] = FixedArray::make(5, 0)
  inspect(run_async(fn() { limited.read(dst, 0, 5) }), content="5")
  inspect(run_async(fn() { limited.read(dst, 0, 5) }), content="5")
  inspect(run_async(fn() { limited.read(dst, 0, 5) }), content="0")
}

test "LimitReader handles underlying EOF" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"hi")
  let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 100)
  
  let dst : FixedArray[Byte] = FixedArray::make(10, 0)
  inspect(run_async(fn() { limited.read(dst, 0, 10) }), content="2")
}

test "LimitReader close and state" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
  let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 5)
  
  inspect(run_async_bool(fn() { limited.is_closed() }), content="false")
  run_async_unit(fn() { limited.close() })
  inspect(run_async_bool(fn() { base_reader.is_closed() }), content="true")
  inspect(run_async_bool(fn() { limited.is_closed() }), content="true")
}

test "LimitReader with zero limit" {
  let buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
  let base_reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(base_reader as &Reader, 0)
  
  let dst : FixedArray[Byte] = FixedArray::make(5, 0)
  inspect(run_async(fn() { limited.read(dst, 0, 5) }), content="0")
}

///| Tests for LimitedWriter
test "LimitedWriter respects write limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(base_writer as &Writer, 5)
  
  let src : FixedArray[Byte] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  let bytes_written = run_async(fn() { limited.write(src, 0, 10) })
  inspect(bytes_written, content="5")
  
  // Further writes return 0
  inspect(run_async(fn() { limited.write(src, 0, 10) }), content="0")
}

test "LimitedWriter multiple writes within limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(base_writer as &Writer, 10)
  
  let src : FixedArray[Byte] = [1, 2, 3, 4, 5]
  inspect(run_async(fn() { limited.write(src, 0, 5) }), content="5")
  inspect(run_async(fn() { limited.write(src, 0, 5) }), content="5")
  inspect(run_async(fn() { limited.write(src, 0, 5) }), content="0")
}

test "LimitedWriter close and state" {
  let buf = @buffer.HeapByteBuf::new(100)
  let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(base_writer as &Writer, 10)
  
  inspect(run_async_bool(fn() { limited.is_closed() }), content="false")
  run_async_unit(fn() { limited.close() })
  inspect(run_async_bool(fn() { base_writer.is_closed() }), content="true")
  inspect(run_async_bool(fn() { limited.is_closed() }), content="true")
}

test "LimitedWriter with zero limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let base_writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(base_writer as &Writer, 0)
  
  let src : FixedArray[Byte] = [1, 2, 3]
  inspect(run_async(fn() { limited.write(src, 0, 3) }), content="0")
}

test "LimitedWriter write_buffer respects limit" {
  let dst_buf = @buffer.HeapByteBuf::new(100)
  let base_writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(base_writer as &Writer, 5)
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let bytes_written = run_async(fn() { limited.write_buffer(src_buf as &@buffer.Buffer) })
  inspect(bytes_written, content="5")
}

///| Tests for TeeReader
test "TeeReader copies data to writer" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  
  let data : FixedArray[Byte] = FixedArray::make(5, 0)
  let bytes_read = run_async(fn() { tee.read(data, 0, 5) })
  inspect(bytes_read, content="5")
  inspect(data[0].to_int(), content="104") // 'h'
  inspect(dst_buf.readable_bytes(), content="5")
}

test "TeeReader handles partial reads and writes" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello world")
  let dst_buf = @buffer.HeapByteBuf::new(3) // Small buffer
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  
  let data : FixedArray[Byte] = FixedArray::make(5, 0)
  let bytes_read = run_async(fn() { tee.read(data, 0, 5) })
  inspect(bytes_read, content="5") // Reads 5
  inspect(dst_buf.readable_bytes(), content="3") // Writes only 3
}

test "TeeReader empty reader" {
  let src_buf = @buffer.HeapByteBuf::new(10)
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  
  let data : FixedArray[Byte] = FixedArray::make(5, 0)
  inspect(run_async(fn() { tee.read(data, 0, 5) }), content="0")
}

test "TeeReader close closes both" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  
  run_async_unit(fn() { tee.close() })
  inspect(run_async_bool(fn() { reader.is_closed() }), content="true")
  inspect(run_async_bool(fn() { writer.is_closed() }), content="true")
  inspect(run_async_bool(fn() { tee.is_closed() }), content="true")
}

test "TeeReader is_closed when both closed" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  
  run_async_unit(fn() { reader.close() })
  run_async_unit(fn() { writer.close() })
  inspect(run_async_bool(fn() { tee.is_closed() }), content="true")
}

test "TeeReader not closed when only one closed" {
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"test")
  let dst_buf = @buffer.HeapByteBuf::new(10)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dst_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  
  run_async_unit(fn() { reader.close() })
  inspect(run_async_bool(fn() { tee.is_closed() }), content="false")
}

///| Tests for DuplexWriter
test "DuplexWriter writes to both writers" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let bytes_written = run_async(fn() { duplex.write(data, 0, 5) })
  inspect(bytes_written, content="5")
  inspect(buf1.readable_bytes(), content="5")
  inspect(buf2.readable_bytes(), content="5")
}

test "DuplexWriter returns minimum written" {
  let buf1 = @buffer.HeapByteBuf::new(3)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let bytes_written = run_async(fn() { duplex.write(data, 0, 5) })
  inspect(bytes_written, content="3")
}

test "DuplexWriter close closes both" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  
  run_async_unit(fn() { duplex.close() })
  inspect(run_async_bool(fn() { writer1.is_closed() }), content="true")
  inspect(run_async_bool(fn() { writer2.is_closed() }), content="true")
  inspect(run_async_bool(fn() { duplex.is_closed() }), content="true")
}

test "DuplexWriter is_closed when both closed" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  
  run_async_unit(fn() { writer1.close() })
  run_async_unit(fn() { writer2.close() })
  inspect(run_async_bool(fn() { duplex.is_closed() }), content="true")
}

test "DuplexWriter not closed when only one closed" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  
  run_async_unit(fn() { writer1.close() })
  inspect(run_async_bool(fn() { duplex.is_closed() }), content="false")
}

test "DuplexWriter write with one closed" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(10)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  
  run_async_unit(fn() { writer1.close() })
  let data : FixedArray[Byte] = [1, 2, 3]
  let bytes_written = run_async(fn() { duplex.write(data, 0, 3) })
  inspect(bytes_written, content="0") // Returns minimum (writer1 returns 0)
}

test "DuplexWriter write_buffer" {
  let buf1 = @buffer.HeapByteBuf::new(20)
  let buf2 = @buffer.HeapByteBuf::new(20)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  let src_buf = @buffer.HeapByteBuf::wrapped_bytes(b"hello")
  let bytes_written = run_async(fn() { duplex.write_buffer(src_buf as &@buffer.Buffer) })
  inspect(bytes_written, content="5")
  inspect(buf1.readable_bytes(), content="5")
  inspect(buf2.readable_bytes(), content="5")
}
