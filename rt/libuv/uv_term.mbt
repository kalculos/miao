///|
struct UvTerminal {
  rt : LibuvRuntime
  stdin : @uv.Tty
  stdout : @uv.Tty
  stderr : @uv.Tty
}

///|
pub fn UvTerminal::new(rt : LibuvRuntime) -> UvTerminal raise {
  let stdin = @uv.Tty::new(rt.uv, @uv.stdin())
  let stdout = @uv.Tty::new(rt.uv, @uv.stdout())
  let stderr = @uv.Tty::new(rt.uv, @uv.stderr())
  UvTerminal::{ rt, stdin, stdout, stderr }
}

///|
impl @process.Terminal for UvTerminal with set_mode(self, mode) {
  self.stdin.set_mode(
    match mode {
      Normal => @uv.TtyMode::normal()
      RawInput => @uv.TtyMode::raw()
    },
  )
}

///|
impl @process.Terminal for UvTerminal with reset_mode(self) {
  (try? @uv.Tty::reset_mode()).unwrap_or(())
}

///|
impl @process.Terminal for UvTerminal with get_window_size(self) {
  (try? self.stdin.get_winsize()).unwrap_or((800, 600))
}

///|
impl @io.Reader for UvTerminal with read(self, dst, off, len) {
  self.stdin.read_start()
}
