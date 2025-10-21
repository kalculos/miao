///|
pub(all) struct DiscardWriter {}

///|
pub fn DiscardWriter::new() -> DiscardWriter {
  DiscardWriter::{  }
}

///|
impl Writer for DiscardWriter with write(self, arr, off, len) {
  len
}

impl Writer for DiscardWriter with close(self) {

}

impl Writer for DiscardWriter with is_closed(self) {
  false
}

