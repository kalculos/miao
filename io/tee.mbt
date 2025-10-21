///|
pub(all) struct TeeReader {
  reader : &Reader
  writer : &Writer
}

///|
pub fn TeeReader::new(reader : &Reader, writer : &Writer) -> TeeReader {
  { reader, writer }
}
