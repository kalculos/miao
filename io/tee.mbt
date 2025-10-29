///|
pub(all) struct TeeReader {
  reader : &Reader
  writer : &Writer
}

///|
pub fn TeeReader::new(reader : &Reader, writer : &Writer) -> TeeReader {
  { reader, writer }
}

///|
pub impl Reader for TeeReader with read(self, dst : FixedArray[Byte], off : Int, len : Int) -> Int {
  let bytes_read = self.reader.read(dst, off, len)
  if bytes_read > 0 {
    // Write the same data to the writer
    let bytes_written = self.writer.write(dst, off, bytes_read)
    // If we couldn't write all bytes, that's okay - we still return the bytes we read
    // The tee pattern continues even if the writer fails
  }
  bytes_read
}

///|
pub impl Reader for TeeReader with close(self) -> Unit {
  self.reader.close()
  self.writer.close()
}

///|
pub impl Reader for TeeReader with is_closed(self) -> Bool {
  self.reader.is_closed() && self.writer.is_closed()
}


///|
pub(all) struct DuplexWriter {
  writer1 : &Writer
  writer2 : &Writer
}

///|
pub fn DuplexWriter::new(writer1 : &Writer, writer2 : &Writer) -> DuplexWriter {
  { writer1, writer2 }
}

///|
pub impl Writer for DuplexWriter with write(self, arr : FixedArray[Byte], off : Int, len : Int) -> Int {
  let bytes_written1 = self.writer1.write(arr, off, len)
  let bytes_written2 = self.writer2.write(arr, off, len)
  // Return the minimum to ensure we don't claim more bytes were written than actually written to both
  @cmp.minimum(bytes_written1, bytes_written2)
}

///|
pub impl Writer for DuplexWriter with close(self) -> Unit {
  self.writer1.close()
  self.writer2.close()
}

///|
pub impl Writer for DuplexWriter with is_closed(self) -> Bool {
  self.writer1.is_closed() && self.writer2.is_closed()
}
