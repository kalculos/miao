///|
let _stdin : Ref[&@io.Reader] = Ref::new(
  @io.EmptyClosedReader::new() as &@io.Reader,
)

///|
let _stdout : Ref[&@io.Writer] = Ref::new(
  @io.DiscardWriter::new() as &@io.Writer,
)

///|
/// win_size() -> (width, height)
pub(open) trait Terminal {
  win_size(Self) -> (Int, Int)
}

///|
let _pty : Ref[&Terminal?] = Ref::new(None)

///|
pub fn stdout() -> &@io.Writer {
  _stdout.val
}

///|
pub fn stdin() -> &@io.Reader {
  _stdin.val
}

///|
pub fn set_stdio(stdout : &@io.Writer, stdin : &@io.Reader) -> Unit {
  _stdin.val = stdin
  _stdout.val = stdout
}

///|
pub fn set_terminal(terminal : &Terminal) -> Unit {
  _pty.val = Some(terminal)
}

///|
pub fn terminal() -> &Terminal? {
  _pty.val
}