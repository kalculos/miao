///|
struct StreamWriter {
  mut closed : Bool
  stream : @uv.Stream
}

///|
pub fn StreamWriter::new(s : @uv.Stream) -> StreamWriter {
  StreamWriter::{ stream: s, closed: false }
}

///|
pub impl @io.Writer for StreamWriter with write(this, arr, off, len) {
  uvrt_op_suspend((resolve, reject, _) => {
      let handle = this.stream.write(
        [arr.unsafe_reinterpret_as_bytes()[off:off + len]],
        () => resolve(len),
        err => reject(err),
      )
      () => ()
    },
    // defer reject(@rt.CoroutineError::Cancelled)
    // todo uv write seems uncancellable?
  )
}

///|
pub impl @io.Writer for StreamWriter with close(this) {
  guard !this.stream.is_closing()
  guard !this.closed
  this.stream.close(() => this.closed = true)
}

///|
pub impl @io.Writer for StreamWriter with is_closed(this) {
  this.closed || this.stream.is_closing()
}

///|
pub fn read_stream(
  rt : &@rt.Runtime,
  stream : @uv.Stream,
  buffer_size? : Int = 16384,
) -> &@io.Reader raise {
  let (reader, writer) = @pipe.BufferedPipe::new(buffer_size~)
  let buffer : FixedArray[Byte] = FixedArray::make(buffer_size, 0)
  rt
  .new_task(_ => while !writer.is_closed() {
    let data = uvrt_op_suspend((resolve, reject, _) => {
      stream.read_start(
        (_, _) => buffer.unsafe_reinterpret_as_bytes(),
        (stream, _, bytes) => resolve(bytes),
        (stream, err) => reject(err),
      )
      () => {
          defer reject(@uv.Errno::ECANCELED)
          stream.read_stop()
        }
    })
    if !writer.can_write(data.length()) {
      stream.read_stop()
    }
    let offset = data.start_offset()
    let len = data.length()
    let mut written = 0
    // two cases here:
    // 1. the buffer has been written into the pipe at one write.
    // 2. The buffer couldn't accept our buffer at once. The libuv loop will "wait" for us since we've called `read_stop` above.
    // Hopefully the reader on the opponent side will read these bytes in-time.
    while written != len && !writer.is_closed() {
      written += writer.write(buffer, offset + written, len)
    }
  })
  .start()
  reader
}

///|
pub fn bytes_reinterpret(b : Bytes) -> FixedArray[Byte] = "%identity"
