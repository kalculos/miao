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