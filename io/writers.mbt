///|
pub(all) struct DiscardWriter {}

///|
pub fn DiscardWriter::new() -> DiscardWriter {
  DiscardWriter::{}
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


