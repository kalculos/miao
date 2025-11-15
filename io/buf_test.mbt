///|
/// Tests for ByteBufReader
async test "ByteBufReader::new creates reader" {
  let buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  inspect(reader.is_closed(), content="false")
}

///|
async test "ByteBufReader::read reads available data" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'a', b'b', b'c', b'd', b'e']
  buf.write(data, 0, data.length()) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let dest : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = reader.read(dest, 0, 10)
  inspect(bytes_read, content="5")
  inspect(dest[0].to_int(), content="97")
  inspect(dest[4].to_int(), content="101")
}

///|
async test "ByteBufReader::read returns 0 when empty" {
  let buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let dest : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = reader.read(dest, 0, 10)
  inspect(bytes_read, content="0")
}

///|
async test "ByteBufReader::read returns 0 when closed" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'x', b'y', b'z']
  buf.write(data, 0, data.length()) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  reader.close()
  let dest : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = reader.read(dest, 0, 10)
  inspect(bytes_read, content="0")
}

///|
async test "ByteBufReader::read respects offset and length" {
  let buf = @buffer.HeapByteBuf::new(100)
  let data : FixedArray[Byte] = [b'1', b'2', b'3', b'4', b'5']
  buf.write(data, 0, data.length()) |> ignore
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  let dest : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = reader.read(dest, 2, 3)
  inspect(bytes_read, content="3")
  inspect(dest[2].to_int(), content="49")
  inspect(dest[3].to_int(), content="50")
  inspect(dest[4].to_int(), content="51")
}

///|
async test "ByteBufReader::close sets closed state" {
  let buf = @buffer.HeapByteBuf::new(100)
  let reader = ByteBufReader::new(buf as &@buffer.Buffer)
  inspect(reader.is_closed(), content="false")
  reader.close()
  inspect(reader.is_closed(), content="true")
}

///|
/// Tests for ByteBufWriter
async test "ByteBufWriter::new creates writer" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  inspect(writer.is_closed(), content="false")
}

///|
async test "ByteBufWriter::write writes data to buffer" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let data : FixedArray[Byte] = [b'h', b'e', b'l', b'l', b'o']
  let bytes_written = writer.write(data, 0, data.length())
  inspect(bytes_written, content="5")
  inspect(buf.readable_bytes(), content="5")
}

///|
async test "ByteBufWriter::write returns 0 when closed" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  writer.close()
  let data : FixedArray[Byte] = [b'a', b'b', b'c']
  let bytes_written = writer.write(data, 0, data.length())
  inspect(bytes_written, content="0")
}

///|
async test "ByteBufWriter::write respects buffer capacity" {
  let buf = @buffer.HeapByteBuf::new(5) // Small buffer
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let data : FixedArray[Byte] = [b'a', b'b', b'c', b'd', b'e', b'f', b'g', b'h']
  let bytes_written = writer.write(data, 0, data.length())
  inspect(bytes_written, content="5") // Only writes what fits
  inspect(buf.readable_bytes(), content="5")
}

///|
async test "ByteBufWriter::write respects offset and length" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  let data : FixedArray[Byte] = [b'0', b'1', b'2', b'3', b'4', b'5']
  let bytes_written = writer.write(data, 2, 3)
  inspect(bytes_written, content="3")
  inspect(buf.readable_bytes(), content="3")
  let result : FixedArray[Byte] = FixedArray::make(3, 0)
  buf.read(result, 0, 3) |> ignore
  inspect(result[0].to_int(), content="50")
  inspect(result[1].to_int(), content="51")
  inspect(result[2].to_int(), content="52")
}

///|
async test "ByteBufWriter::close sets closed state" {
  let buf = @buffer.HeapByteBuf::new(100)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)
  inspect(writer.is_closed(), content="false")
  writer.close()
  inspect(writer.is_closed(), content="true")
}

///|
async test "ByteBufWriter::write returns 0 when buffer is full" {
  let buf = @buffer.HeapByteBuf::new(3)
  let writer = ByteBufWriter::new(buf as &@buffer.Buffer)

  // Fill the buffer
  let data1 : FixedArray[Byte] = [b'a', b'b', b'c']
  writer.write(data1, 0, 3) |> ignore

  // Try to write more
  let data2 : FixedArray[Byte] = [b'd', b'e']
  let bytes_written = writer.write(data2, 0, 2)
  inspect(bytes_written, content="0")
}
