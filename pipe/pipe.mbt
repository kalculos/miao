///|
struct BufferedPipe {
  rt : &@rt.Runtime
  // Buffer fields
  buf : FixedArray[Byte]
  mut ridx : Int
  mut widx : Int
  // Lock fields
  mut read_waiting : Bool
  mut read_waiter : () -> Unit
  mut write_waiting : Bool
  mut write_waiter : () -> Unit
}

///|
pub trait PipeWriter: @io.Writer {
  can_write(Self, amount : Int) -> Bool
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
/// The pair of reader and writer cannot be shared by multiple producer and consumers (multiple coroutines),
/// otherwise it threw a error in previous blocked callsite.
/// 
/// The implementation only supports single-threaded concurrency model.
pub fn BufferedPipe::new(
  runtime? : &@rt.Runtime = @rt.current_runtime(),
  buffer_size? : Int = 16384,
) -> (&@io.Reader, &PipeWriter) {
  guard buffer_size >= 0  // 0 => direct pipe
  let pipe = BufferedPipe::{
    rt: runtime,
    buf: FixedArray::make(buffer_size, 0),
    ridx: 0,
    widx: 0,
    read_waiting: false,
    read_waiter: () => (),
    write_waiting: false,
    write_waiter: () => (),
  }
  (pipe as &@io.Reader, pipe as &PipeWriter)
}

///|
fn BufferedPipe::avail(self: BufferedPipe) -> Int {
  let val = self.widx - self.ridx
  guard val >= 0 else { return self.buf.length() - self.ridx + self.widx }
  val
}

///|
fn BufferedPipe::_is_closed(self: BufferedPipe) -> Bool {
  self.widx == -1
}

///|
fn BufferedPipe::_close(self: BufferedPipe) -> Unit {
  guard !self._is_closed()
  self.widx = -1
}

///|
pub impl @io.Reader for BufferedPipe with available(self) {
  if self._is_closed() {
    return 0
  }
  self.avail()
}

///|
fn BufferedPipe::advance_reader_idx(self: BufferedPipe, delta? : Int = 1) -> Int {
  let v = self.ridx
  self.ridx = (self.ridx + delta) % self.buf.length()
  v
}

///|
fn BufferedPipe::advance_writer_idx(self: BufferedPipe, delta? : Int = 1) -> Int {
  let v = self.widx
  self.widx = (self.widx + delta) % self.buf.length()
  v
}

///|
pub impl @io.Reader for BufferedPipe with read(self, dst, off, len) {
  if self._is_closed() {
    return 0
  }
  if self.avail() == 0 {
    // go to wait
    self.block_read()
    if self._is_closed() {
      return 0
    }
  }
  let read = @cmp.minimum(len, self.avail())
  let len = self.buf.length()
  if self.ridx + read > len {
    let copied = len - self.ridx
    self.buf.blit_to(
      dst,
      len=copied,
      src_offset=self.advance_reader_idx(delta=read),
      dst_offset=off,
    )
    self.buf.blit_to(dst, len=self.ridx, src_offset=0, dst_offset=copied)
  }
  for i = 0; i < read; i = i + 1 {
    dst[off + i] = self.buf[self.advance_reader_idx() % len]
  }
  if self.write_waiting {
    self.rt.new_task(_ => (self.write_waiter)()).start()
  }
  read
}

///|
pub impl @io.Writer for BufferedPipe with write(self, arr, off, len) {
  if self._is_closed() {
    return 0
  }
  if !self.can_write(len) {
    self.block_write()
    if self._is_closed() {
      return 0
    }
  }
  let written = @cmp.minimum(len, self.avail())
  if self.widx + written > self.buf.length() {
    let copied = self.buf.length() - self.widx
    arr.blit_to(
      self.buf,
      len=copied,
      src_offset=off,
      dst_offset=self.advance_writer_idx(delta=written),
    )
    arr.blit_to(
      self.buf,
      len=len - copied,
      src_offset=off + copied,
      dst_offset=0,
    )
  } else {
    arr.blit_to(
      self.buf,
      len=written,
      src_offset=off,
      dst_offset=self.advance_writer_idx(delta=written),
    )
  }
  if written != 0 && self.read_waiting {
    self.rt.new_task(_ => (self.read_waiter)()).start()
  }
  written
}

///|
async fn BufferedPipe::block_read(self: BufferedPipe) -> Unit {
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
async fn BufferedPipe::block_write(self: BufferedPipe) -> Unit {
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
pub impl PipeWriter for BufferedPipe with can_write(self, amount) {
  !self._is_closed() && self.buf.length() - self.avail() >= amount
}
