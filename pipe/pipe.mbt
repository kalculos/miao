///|
struct BufferedPipe {
  buf : FixedArray[Byte]
  rt : &@rt.Runtime
  mut len : Int
  mut off : Int
  mut read_waiter : (Bool) -> Unit
  mut write_waiter : (Bool) -> Unit
}

///|
trait PipeWriter: @io.Writer {
  can_write(Self) -> Bool
}

///|
/// Return a pair of a special reader and a special writer.
/// The reader will block until more data is available until the pipe is closed.
/// When the reader returns 0, there is no more data to read. (the pipe is closed)
/// Users should check Reader#available beforehand to avoid blocking, if needed.
/// 
/// The writer will also block if the buffer isn't empty. However, simliar to the Reader side,
/// you may check PipeWriter#can_write() to avoid blocking or doing something else, like 
/// unregistering your callback until next write.
/// 
/// The pair of reader and writer cannot be shared by multiple producer and consumers (in different coroutines),
/// otherwise it threw a error in previous blocked callsite.
pub fn BufferedPipe::new(
  runtime : &@rt.Runtime,
  buffer_size? : Int = 16384,
) -> (&@io.Reader, &PipeWriter) {
  guard buffer_size >= 0  // 0 => direct pipe
  let pipe = BufferedPipe::{
    buf: FixedArray::make(buffer_size, 0),
    rt: runtime,
    len: 0,
    off: 0,
    read_waiter: _ => (),
    write_waiter: _ => (),
  }
  (pipe as &@io.Reader, pipe as &PipeWriter)
}

///|
fn avail(self : BufferedPipe) -> Int {
  self.len - self.off
}

///|
fn _is_closed(self : BufferedPipe) -> Bool {
  self.len == -1
}

///|
fn _close(self : BufferedPipe) -> Unit {
  guard !self._is_closed()
  self.len = -1
}

///|
impl @io.Reader for BufferedPipe with available(self) {
  if self._is_closed() {
    return 0
  }
  self.avail()
}

///|
impl @io.Reader for BufferedPipe with read(self, dst, off, len) {
  if self._is_closed() {
    return 0
  }
  if self.avail() == 0 {
    // go to wait
    self.block_read()
  }
  let read = @cmp.minimum(len, self.avail())
  for i = 0; i < read; i = i + 1 {
    dst[off + i] = self.buf[self.off + i]
  }
  self.off = self.off + read
  if self.avail() == 0 {
    self.rt.new_task(_ => (self.write_waiter)(true)).start() 
  }
  read
}

///|
impl @io.Writer for BufferedPipe with write(self, arr, off, len) {
  if self._is_closed() {
    return 0
  }
  if !self.can_write() {
    self.block_write()
  }
  let written = @cmp.minimum(len, self.buf.length())
  for i = 0; i < written; i = i + 1 {
    self.buf[i] = arr[off + i]
  }
  if written != 0 {
    self.rt.new_task(_ => (self.read_waiter)(true)).start()
  }
  written
}

///|
async fn block_read(self : BufferedPipe) -> Unit {
  self.rt.suspend((onResolve, onReject, _) => {
    (self.read_waiter)(false)
    self.read_waiter = succ => {
        defer (fn() { self.read_waiter = _ => () })()
        guard succ else {
          onReject(
            Failure("Someone called read() while someone is already waiting!"),
          )
        }
        onResolve(())
      }
      () => ()
  })
}

///|
async fn block_write(self : BufferedPipe) -> Unit {
  self.rt.suspend((onResolve, onReject, _) => {
    (self.write_waiter)(false)
    self.write_waiter = succ => {
        defer (fn() { self.write_waiter = _ => () })()
        guard succ else {
          onReject(
            Failure("Someone called write() while someone is already waiting!"),
          )
        }
        onResolve(())
      }
    () => ()
  })
}

///|
impl @io.Writer for BufferedPipe with close(self) {
  self._close()
}

///|
impl @io.Writer for BufferedPipe with is_closed(self) {
  self._is_closed()
}

///|
impl @io.Reader for BufferedPipe with close(self) {
  self._close()
}

///|
impl @io.Reader for BufferedPipe with is_closed(self) {
  self._is_closed()
}

///|
impl PipeWriter for BufferedPipe with can_write(self) {
  self.avail() == 0 && !self._is_closed()
}
