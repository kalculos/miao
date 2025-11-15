///|
/// Tests for DiscardWriter
async test "DiscardWriter::new creates writer" {
  let writer = DiscardWriter::new()
  inspect(writer.is_closed(), content="false")
}

///|
async test "DiscardWriter::write always succeeds" {
  let writer = DiscardWriter::new()
  let data : FixedArray[Byte] = [b'a', b'b', b'c', b'd', b'e']
  let bytes_written = writer.write(data, 0, data.length())
  inspect(bytes_written, content="5")
}

///|
async test "DiscardWriter::write returns requested length" {
  let writer = DiscardWriter::new()
  let data : FixedArray[Byte] = FixedArray::make(1000, b'x')
  let bytes_written = writer.write(data, 0, 1000)
  inspect(bytes_written, content="1000")
}

///|
async test "DiscardWriter::write respects length parameter" {
  let writer = DiscardWriter::new()
  let data : FixedArray[Byte] = [b'1', b'2', b'3', b'4', b'5']
  let bytes_written = writer.write(data, 0, 3)
  inspect(bytes_written, content="3")
}

///|
async test "DiscardWriter::is_closed always returns false" {
  let writer = DiscardWriter::new()
  inspect(writer.is_closed(), content="false")
  writer.close()
  inspect(writer.is_closed(), content="false")
}

///|
async test "DiscardWriter::close does nothing" {
  let writer = DiscardWriter::new()
  writer.close()

  // Should still be able to write
  let data : FixedArray[Byte] = [b'a', b'b']
  let bytes_written = writer.write(data, 0, 2)
  inspect(bytes_written, content="2")
}

///|
/// Tests for EmptyClosedReader
async test "EmptyClosedReader::new creates reader" {
  let reader = EmptyClosedReader::new()
  inspect(reader.is_closed(), content="true")
}

///|
async test "EmptyClosedReader::read always returns 0" {
  let reader = EmptyClosedReader::new()
  let dest : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = reader.read(dest, 0, 10)
  inspect(bytes_read, content="0")
}

///|
async test "EmptyClosedReader::is_closed always returns true" {
  let reader = EmptyClosedReader::new()
  inspect(reader.is_closed(), content="true")
}

///|
async test "EmptyClosedReader::close does nothing" {
  let reader = EmptyClosedReader::new()
  reader.close()
  inspect(reader.is_closed(), content="true")
}

///|
async test "EmptyClosedReader::read with different parameters" {
  let reader = EmptyClosedReader::new()
  let dest : FixedArray[Byte] = FixedArray::make(100, 0)
  let bytes_read1 = reader.read(dest, 0, 1)
  let bytes_read2 = reader.read(dest, 10, 50)
  let bytes_read3 = reader.read(dest, 0, 100)
  inspect(bytes_read1, content="0")
  inspect(bytes_read2, content="0")
  inspect(bytes_read3, content="0")
}
