///|
/// Tests for TeeReader
async test "TeeReader::new creates tee reader" {
  let buf1 = @buffer.HeapByteBuf::new(100)
  let buf2 = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(buf1 as &@buffer.Buffer)
  let writer = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  inspect(tee.is_closed(), content="false")
}

///|
async test "TeeReader::read copies data to writer" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'H', b'e', b'l', b'l', b'o']
  src_buf.write(data, 0, data.length()) |> ignore
  let dest_buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  let output : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = tee.read(output, 0, 10)
  inspect(bytes_read, content="5")
  inspect(dest_buf.readable_bytes(), content="5") // Data was copied to writer

  // Verify data in output
  inspect(output[0].to_int(), content="72")
  inspect(output[4].to_int(), content="111")
}

///|
async test "TeeReader::read writes same data to tee writer" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'T', b'e', b's', b't']
  src_buf.write(data, 0, 4) |> ignore
  let dest_buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  let output : FixedArray[Byte] = FixedArray::make(10, 0)
  tee.read(output, 0, 10) |> ignore

  // Verify data in destination buffer
  let tee_data : FixedArray[Byte] = FixedArray::make(4, 0)
  dest_buf.read(tee_data, 0, 4) |> ignore
  inspect(tee_data[0].to_int(), content="84")
  inspect(tee_data[3].to_int(), content="116")
}

///|
async test "TeeReader::read handles empty reader" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let dest_buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  let output : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = tee.read(output, 0, 10)
  inspect(bytes_read, content="0")
  inspect(dest_buf.readable_bytes(), content="0")
}

///|
async test "TeeReader::close closes both reader and writer" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let dest_buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  inspect(tee.is_closed(), content="false")
  tee.close()
  inspect(tee.is_closed(), content="true")
}

///|
async test "TeeReader::read continues when writer is full" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = FixedArray::make(20, b'A')
  src_buf.write(data, 0, 20) |> ignore
  let dest_buf = @buffer.HeapByteBuf::new(5) // Small writer buffer
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let tee = TeeReader::new(reader as &Reader, writer as &Writer)
  let output : FixedArray[Byte] = FixedArray::make(20, 0)
  let bytes_read = tee.read(output, 0, 20)
  inspect(bytes_read, content="20") // Still reads all data
  inspect(dest_buf.readable_bytes(), content="5") // Writer only got 5 bytes
}

///|
/// Tests for DuplexWriter
async test "DuplexWriter::new creates duplex writer" {
  let buf1 = @buffer.HeapByteBuf::new(100)
  let buf2 = @buffer.HeapByteBuf::new(100)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  inspect(duplex.is_closed(), content="false")
}

///|
async test "DuplexWriter::write writes to both writers" {
  let buf1 = @buffer.HeapByteBuf::new(100)
  let buf2 = @buffer.HeapByteBuf::new(100)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  let data : FixedArray[Byte] = [b'D', b'u', b'a', b'l']
  let bytes_written = duplex.write(data, 0, 4)
  inspect(bytes_written, content="4")
  inspect(buf1.readable_bytes(), content="4")
  inspect(buf2.readable_bytes(), content="4")
}

///|
async test "DuplexWriter::write returns minimum bytes written" {
  let buf1 = @buffer.HeapByteBuf::new(10)
  let buf2 = @buffer.HeapByteBuf::new(5) // Smaller buffer
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  let data : FixedArray[Byte] = FixedArray::make(10, b'X')
  let bytes_written = duplex.write(data, 0, 10)
  inspect(bytes_written, content="5") // Returns minimum
}

///|
async test "DuplexWriter::write same data to both buffers" {
  let buf1 = @buffer.HeapByteBuf::new(100)
  let buf2 = @buffer.HeapByteBuf::new(100)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  let data : FixedArray[Byte] = [b'S', b'a', b'm', b'e']
  duplex.write(data, 0, 4) |> ignore

  // Verify both buffers have the same data
  let result1 : FixedArray[Byte] = FixedArray::make(4, 0)
  let result2 : FixedArray[Byte] = FixedArray::make(4, 0)
  buf1.read(result1, 0, 4) |> ignore
  buf2.read(result2, 0, 4) |> ignore
  inspect(result1[0].to_int(), content="83")
  inspect(result2[0].to_int(), content="83")
  inspect(result1[3].to_int(), content="101")
  inspect(result2[3].to_int(), content="101")
}

///|
async test "DuplexWriter::close closes both writers" {
  let buf1 = @buffer.HeapByteBuf::new(100)
  let buf2 = @buffer.HeapByteBuf::new(100)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  inspect(duplex.is_closed(), content="false")
  duplex.close()
  inspect(duplex.is_closed(), content="true")
}

///|
async test "DuplexWriter::write with different capacities" {
  let buf1 = @buffer.HeapByteBuf::new(20)
  let buf2 = @buffer.HeapByteBuf::new(15)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  let data : FixedArray[Byte] = FixedArray::make(20, b'C')
  let bytes_written = duplex.write(data, 0, 20)
  inspect(bytes_written, content="15") // Limited by smaller buffer
  inspect(buf1.readable_bytes(), content="20")
  inspect(buf2.readable_bytes(), content="15")
}

///|
async test "DuplexWriter::write respects offset and length" {
  let buf1 = @buffer.HeapByteBuf::new(100)
  let buf2 = @buffer.HeapByteBuf::new(100)
  let writer1 = ByteBufWriter::new(buf1 as &@buffer.Buffer)
  let writer2 = ByteBufWriter::new(buf2 as &@buffer.Buffer)
  let duplex = DuplexWriter::new(writer1 as &Writer, writer2 as &Writer)
  let data : FixedArray[Byte] = [b'0', b'1', b'2', b'3', b'4', b'5']
  let bytes_written = duplex.write(data, 2, 3)
  inspect(bytes_written, content="3")
  let result1 : FixedArray[Byte] = FixedArray::make(3, 0)
  buf1.read(result1, 0, 3) |> ignore
  inspect(result1[0].to_int(), content="50")
  inspect(result1[2].to_int(), content="52")
  let result2 : FixedArray[Byte] = FixedArray::make(3, 0)
  buf2.read(result2, 0, 3) |> ignore
  inspect(result2[0].to_int(), content="50")
  inspect(result2[2].to_int(), content="52")
}
