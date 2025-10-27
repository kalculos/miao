///|
pub(all) struct DiscardWriter {}

///|
pub fn DiscardWriter::new() -> DiscardWriter {
  DiscardWriter::{  }
}

///|
impl Writer for DiscardWriter with write(_, _, _, len) {
  len
}

impl Writer for DiscardWriter with close(_) {

}

impl Writer for DiscardWriter with is_closed(_) {
  false
}

