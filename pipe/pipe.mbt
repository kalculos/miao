///|
struct BufferedPipe {
  buf : FixedArray[Byte]
  rt : &@rt.Runtime
  mut len : Int
  mut off : Int
  mut read_waiting : Bool
  mut read_waiter : () -> Unit
  mut write_waiting : Bool
  mut write_waiter : () -> Unit
}

///|
pub trait PipeWriter: @io.Writer {
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
  runtime? : &@rt.Runtime = @rt.current_runtime(),
  buffer_size? : Int = 16384,
) -> (&@io.Reader, &PipeWriter) {
  guard buffer_size >= 0  // 0 => direct pipe
  let pipe = BufferedPipe::{
    buf: FixedArray::make(buffer_size, 0),
    rt: runtime,
    len: 0,
    off: 0,
    read_waiting: false,
    read_waiter: () => (),
    write_waiting: false,
    write_waiter: () => (),
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
pub impl @io.Reader for BufferedPipe with available(self) {
  if self._is_closed() {
    return 0
  }
  self.avail()
}

///|
pub impl @io.Reader for BufferedPipe with read(self, dst, off, len) {
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
  if self.avail() == 0 && self.write_waiting {
    self.rt.new_task(_ => (self.write_waiter)()).start()
  }
  read
}

///|
pub impl @io.Writer for BufferedPipe with write(self, arr, off, len) {
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
  if written != 0 && self.read_waiting {
    self.rt.new_task(_ => (self.read_waiter)()).start()
  }
  written
}

///|
async fn block_read(self : BufferedPipe) -> Unit {
  guard !self.read_waiting else {
    raise fail("Someone called read() while someone is already waiting!")
  }
  self.read_waiting = true
  defer (fn() { self.read_waiting = false })()
  self.rt.suspend((onResolve, onReject, _) => {
    self.read_waiter = () => {
        defer (fn() { self.read_waiter = () => () })()
        onResolve(())
      }
    () => onReject(@rt.CoroutineError::Cancelled)
  })
}

///|
async fn block_write(self : BufferedPipe) -> Unit {
  guard !self.write_waiting else {
    raise fail("Someone called write() while someone is already waiting!")
  }
  self.write_waiting = true
  defer (fn() { self.write_waiting = false })()
  self.rt.suspend((onResolve, onReject, _) => {
    self.write_waiter = () => {
        defer (fn() { self.write_waiter = () => () })()
        onResolve(())
      }
    () => onReject(@rt.CoroutineError::Cancelled)
  })
}

///|
pub impl @io.Writer for BufferedPipe with close(self) {
  self._close()
}

///|
pub impl @io.Writer for BufferedPipe with is_closed(self) {
  self._is_closed()
}

///|
pub impl @io.Reader for BufferedPipe with close(self) {
  self._close()
}

///|
pub impl @io.Reader for BufferedPipe with is_closed(self) {
  self._is_closed()
}

///|
pub impl PipeWriter for BufferedPipe with can_write(self) {
  self.avail() == 0 && !self._is_closed()
}
