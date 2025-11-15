///|
pub(all) struct LimitReader {
  reader : &Reader
  mut remaining : Int
}

///|
pub fn LimitReader::new(reader : &Reader, limit : Int) -> LimitReader {
  { reader, remaining: limit }
}

///|
pub(all) struct LimitedWriter {
  inner : &Writer
  priv mut remaining : Int
}

///|
pub fn LimitedWriter::new(writer : &Writer, limit : Int) -> LimitedWriter {
  LimitedWriter::{ inner: writer, remaining: limit }
}

///|
pub impl Reader for LimitReader with read(
  self,
  dst : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  if self.remaining <= 0 {
    return 0
  }
  let to_read = @cmp.minimum(len, self.remaining)
  let bytes_read = self.reader.read(dst, off, to_read)
  if bytes_read > 0 {
    self.remaining -= bytes_read
  }
  bytes_read
}

///|
pub impl Reader for LimitReader with close(self) -> Unit {
  self.reader.close()
}

///|
pub impl Reader for LimitReader with is_closed(self) -> Bool {
  self.reader.is_closed()
}

///|
pub impl Writer for LimitedWriter with write(
  self,
  arr : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  if self.remaining <= 0 {
    return 0
  }
  let to_write = @cmp.minimum(len, self.remaining)
  let bytes_written = self.inner.write(arr, off, to_write)
  if bytes_written > 0 {
    self.remaining -= bytes_written
  }
  bytes_written
}

///|
pub impl Writer for LimitedWriter with close(self) -> Unit {
  self.inner.close()
}

///|
pub impl Writer for LimitedWriter with is_closed(self) -> Bool {
  self.inner.is_closed()
}
