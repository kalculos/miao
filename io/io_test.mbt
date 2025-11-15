///|
/// Tests for basic Reader trait methods
async test "Reader::read_all drains entire buffer" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [
    b'H', b'e', b'l', b'l', b'o', b' ', b'W', b'o', b'r', b'l', b'd',
  ]
  buf.write(data, 0, data.length()) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let result = reader.read_all()
  inspect(result.readable_bytes(), content="11")
  let output : FixedArray[Byte] = FixedArray::make(11, 0)
  result.read(output, 0, 11) |> ignore
  inspect(output[0].to_int(), content="72")
  inspect(output[10].to_int(), content="100")
}

///|
async test "Reader::read_buffer reads specified length" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [
    b'H', b'e', b'l', b'l', b'o', b' ', b'W', b'o', b'r', b'l', b'd',
  ]
  buf.write(data, 0, data.length()) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let result = reader.read_buffer(5)
  inspect(result.readable_bytes(), content="5")
  let output : FixedArray[Byte] = FixedArray::make(5, 0)
  result.read(output, 0, 5) |> ignore
  inspect(output[0].to_int(), content="72")
  inspect(output[4].to_int(), content="111")
}

///|
async test "Reader::read_buffer stops at EOF" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'H', b'i']
  buf.write(data, 0, data.length()) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let result = reader.read_buffer(10) // Request more than available
  inspect(result.readable_bytes(), content="2") // Only reads available bytes
}

///|
async test "Reader::read_buffer_to writes to existing buffer" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'T', b'e', b's', b't']
  src_buf.write(data, 0, data.length()) |> ignore
  let reader = ByteBufReader::new(src_buf as &@buffer.Buffer)
  let dest_buf = @buffer.HeapByteBuf::new(100)
  let bytes_read = reader.read_buffer_to(dest_buf as &@buffer.Buffer)
  inspect(bytes_read, content="4")
  inspect(dest_buf.readable_bytes(), content="4")
}

///|
async test "Reader::available returns positive when data available" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'A']
  buf.write(data, 0, 1) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let avail = reader.available()
  inspect(avail > 0, content="true")
}

///|
async test "Reader::available returns zero when closed" {
  let buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  reader.close()
  let avail = reader.available()
  inspect(avail, content="0")
}

///|
/// Tests for Writer trait methods
async test "Writer::write_buffer writes all data" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'D', b'a', b't', b'a']
  src_buf.write(data, 0, data.length()) |> ignore
  let dest_buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let bytes_written = writer.write_buffer(src_buf as &@buffer.Buffer)
  inspect(bytes_written, content="4")
  inspect(dest_buf.readable_bytes(), content="4")
}

///|
async test "Writer::write_buffer handles large data" {
  let src_buf = @buffer.HeapByteBuf::new(2048)
  let large_data : FixedArray[Byte] = FixedArray::make(2000, b'X')
  src_buf.write(large_data, 0, 2000) |> ignore
  let dest_buf = @buffer.HeapByteBuf::new(3000)
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let bytes_written = writer.write_buffer(src_buf as &@buffer.Buffer)
  inspect(bytes_written, content="2000")
  inspect(dest_buf.readable_bytes(), content="2000")
}

///|
async test "Writer::write_buffer stops when writer is full" {
  let src_buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = FixedArray::make(50, b'A')
  src_buf.write(data, 0, 50) |> ignore
  let dest_buf = @buffer.HeapByteBuf::new(30) // Smaller destination
  let writer = ByteBufWriter::new(dest_buf as &@buffer.Buffer)
  let bytes_written = writer.write_buffer(src_buf as &@buffer.Buffer)
  inspect(bytes_written, content="30") // Only writes what fits
  inspect(dest_buf.readable_bytes(), content="30")
}
