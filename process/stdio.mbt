///|
pub enum TtyMode {
  Normal
  RawInput
}

///|
pub(open) trait Terminal: @io.Channel {
  mode(Self) -> TtyMode
  set_mode(Self, TtyMode) -> Unit
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
pub fn stdout() -> &@io.Writer {
  terminal()
}

///|
pub fn stdin() -> &@io.Reader {
  terminal()
}

pub fn terminal() -> &Terminal {
  _terminal.val.unwrap()
}