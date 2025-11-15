///|
pub(all) struct DiscardWriter {}

///|
pub fn DiscardWriter::new() -> DiscardWriter {
  DiscardWriter::{  }
}

///|
pub impl Writer for DiscardWriter with write(_, _, _, len) {
  len
}

///|
pub impl Writer for DiscardWriter with close(_) {

}

///|
pub impl Writer for DiscardWriter with is_closed(_) {
  false
}

///|
pub(all) struct EmptyClosedReader {}

///|
pub fn EmptyClosedReader::new() -> EmptyClosedReader {
  EmptyClosedReader::{  }
}

///|
pub impl Reader for EmptyClosedReader with read(_, _, _, _) {
  0
}

///|
pub impl Reader for EmptyClosedReader with close(_) {

}

///|
pub impl Reader for EmptyClosedReader with is_closed(_) {
  true
}
