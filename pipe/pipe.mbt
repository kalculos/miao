///|
struct BufferedPipe {
  queue : ArrayBlockingQueue[Byte]
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
    queue: ArrayBlockingQueue::new(runtime, buffer_size, 0),
  }
  (pipe as &@io.Reader, pipe as &PipeWriter)
}

///|
pub impl @io.Reader for BufferedPipe with available(self) {
  self.queue.available()
}

///|
pub impl @io.Reader for BufferedPipe with read(self, dst, off, len) {
  self.queue.read_into(dst, off, len)
}

///|
pub impl @io.Writer for BufferedPipe with write(self, arr, off, len) {
  self.queue.write_from(arr, off, len)
}

///|
pub impl @io.Writer for BufferedPipe with close(self) {
  self.queue.close()
}

///|
pub impl @io.Writer for BufferedPipe with is_closed(self) {
  self.queue.is_closed()
}

///|
pub impl @io.Reader for BufferedPipe with close(self) {
  self.queue.close()
}

///|
pub impl @io.Reader for BufferedPipe with is_closed(self) {
  self.queue.is_closed()
}

///|
pub impl PipeWriter for BufferedPipe with can_write(self, amount) {
  self.queue.can_write(amount)
}
