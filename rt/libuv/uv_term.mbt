///|
fn init_uv_term(self : LibuvRuntime) -> Unit raise {
  let stdin = @uv.Tty::new(self.uv, @uv.stdin())
  let stdout = @uv.Tty::new(self.uv, @uv.stdout())
  @process.set_stdio(
    StreamWriter::new(stdout.to_stream()),
    read_stream(self, stdin.to_stream(), buffer_size=16384),
  )
  @process.set_terminal(UvTerminal::{ stdout, })
}

///|
struct UvTerminal {
  stdout : @uv.Tty
}

///|
impl @process.Terminal for UvTerminal with win_size(self) {
  (try? self.stdout.get_winsize()).unwrap_or((800, 600))
}
