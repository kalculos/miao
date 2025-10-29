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

pub impl Writer for DiscardWriter with close(_) {

}

pub impl Writer for DiscardWriter with is_closed(_) {
  false
}

