///|
/// Tests for LimitReader
async test "LimitReader::new creates limited reader" {
  let buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 10)
  inspect(limited.is_closed(), content="false")
}

///|
async test "LimitReader::read respects limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = FixedArray::make(50, b'A')
  buf.write(data, 0, 50) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 10)
  let dest : FixedArray[Byte] = FixedArray::make(50, 0)
  let bytes_read = limited.read(dest, 0, 50)
  inspect(bytes_read, content="10") // Only reads up to limit
}

///|
async test "LimitReader::read returns 0 after limit reached" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = FixedArray::make(50, b'B')
  buf.write(data, 0, 50) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 5)
  let dest : FixedArray[Byte] = FixedArray::make(10, 0)
  limited.read(dest, 0, 10) |> ignore // Read 5 bytes
  let bytes_read = limited.read(dest, 0, 10)
  inspect(bytes_read, content="0") // No more bytes available
}

///|
async test "LimitReader::read multiple times until limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = FixedArray::make(20, b'C')
  buf.write(data, 0, 20) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 10)
  let dest : FixedArray[Byte] = FixedArray::make(5, 0)
  let read1 = limited.read(dest, 0, 5)
  let read2 = limited.read(dest, 0, 5)
  let read3 = limited.read(dest, 0, 5)
  inspect(read1, content="5")
  inspect(read2, content="5")
  inspect(read3, content="0") // Limit reached
}

///|
async test "LimitReader::read with limit larger than data" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'1', b'2', b'3']
  buf.write(data, 0, 3) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 100)
  let dest : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = limited.read(dest, 0, 10)
  inspect(bytes_read, content="3") // Only reads available data
}

///|
async test "LimitReader::close closes underlying reader" {
  let buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let limited = LimitReader::new(reader as &Reader, 10)
  inspect(limited.is_closed(), content="false")
  limited.close()
  inspect(limited.is_closed(), content="true")
}

///|
/// Tests for LimitedWriter
async test "LimitedWriter::new creates limited writer" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(writer as &Writer, 20)
  inspect(limited.is_closed(), content="false")
}

///|
async test "LimitedWriter::write respects limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(writer as &Writer, 10)
  let data : FixedArray[Byte] = FixedArray::make(50, b'X')
  let bytes_written = limited.write(data, 0, 50)
  inspect(bytes_written, content="10") // Only writes up to limit
  inspect(buf.readable_bytes(), content="10")
}

///|
async test "LimitedWriter::write returns 0 after limit reached" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(writer as &Writer, 5)
  let data : FixedArray[Byte] = FixedArray::make(10, b'Y')
  limited.write(data, 0, 10) |> ignore // Write 5 bytes
  let bytes_written = limited.write(data, 0, 10)
  inspect(bytes_written, content="0") // No more writes allowed
}

///|
async test "LimitedWriter::write multiple times until limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(writer as &Writer, 10)
  let data : FixedArray[Byte] = FixedArray::make(5, b'Z')
  let written1 = limited.write(data, 0, 5)
  let written2 = limited.write(data, 0, 5)
  let written3 = limited.write(data, 0, 5)
  inspect(written1, content="5")
  inspect(written2, content="5")
  inspect(written3, content="0") // Limit reached
  inspect(buf.readable_bytes(), content="10")
}

///|
async test "LimitedWriter::write with zero limit" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(writer as &Writer, 0)
  let data : FixedArray[Byte] = [b'a', b'b', b'c']
  let bytes_written = limited.write(data, 0, 3)
  inspect(bytes_written, content="0")
}

///|
async test "LimitedWriter::close closes underlying writer" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(writer as &Writer, 20)
  inspect(limited.is_closed(), content="false")
  limited.close()
  inspect(limited.is_closed(), content="true")
}

///|
async test "LimitedWriter::write partial writes decrease remaining" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let limited = LimitedWriter::new(writer as &Writer, 15)
  let data1 : FixedArray[Byte] = FixedArray::make(7, b'1')
  let data2 : FixedArray[Byte] = FixedArray::make(7, b'2')
  let written1 = limited.write(data1, 0, 7)
  let written2 = limited.write(data2, 0, 7)
  inspect(written1, content="7")
  inspect(written2, content="7") // Only 8 bytes remaining, writes 7
  inspect(buf.readable_bytes(), content="14")
}
