///|
pub enum TtyMode {
  Normal
  RawInput
}

pub(open) trait StdinReader : @io.Reader {}

pub(open) trait StdoutWriter : @io.Writer {}

///|
pub(open) trait Terminal: StdinReader + StdoutWriter {
  set_mode(Self, TtyMode) -> Unit raise
  reset_mode(Self) -> Unit
  get_window_size(Self) -> (Int, Int)
}

///|
let _terminal : Ref[&Terminal?] = Ref::new(None)

///|
pub fn set_terminal(term : &Terminal) -> Unit {
  _terminal.val = Some(term)
}

///|
pub fn stdout() -> &StdoutWriter {
  terminal()
}

///|
pub fn stdin() -> &StdinReader {
  terminal()
}

pub fn terminal() -> &Terminal {
  _terminal.val.unwrap()
}