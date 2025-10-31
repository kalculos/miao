///| Default buffer size for I/O operations
let default_buffer_size : Int = 1024

///|
pub(open) trait Reader {
  /// Read a specific amount of bytes at most, to the destinated buffer.
  /// It returns the actual bytes read or 0 if the Reader is closed or drained.
  async read(Self, dst : FixedArray[Byte], off : Int, len : Int) -> Int
  /// Read bytes to a bytebuffer until the reader is drained or closed.
  async read_all(Self) -> &@buffer.Buffer = _
  async read_buffer(Self, len : Int) -> &@buffer.Buffer = _
  /// Read (buf.len - off) bytes at most to the buffer.
  async read_buffer_to(Self, buf : &@buffer.Buffer) -> Int = _
  /// Check if there are available bytes. When any bytes available, it returns a positive value. Otherwise, zero or negative is returned.
  /// It does not guarantee the return value equals to the number of bytes you can read.
  async available(Self) -> Int = _
  async close(Self) -> Unit
  ///| This also indicates the state of closer
  async is_closed(Self) -> Bool
}

///|
pub(open) trait Writer {
  /// Write a byte array and returns the bytes that we actually write.
  async write(Self, arr : FixedArray[Byte], off : Int, len : Int) -> Int
  /// Write to the writer. The buffer must support marking & seeking
  /// It returns the bytes actually written. 
  async write_buffer(
    Self,
    buf : &@buffer.Buffer, // a sliced buffer can be used to control if reader index should inc. Or also supports skipN
  ) -> Int = _
  async close(Self) -> Unit
  ///| This also indicates the state of closer
  async is_closed(Self) -> Bool
}

impl Reader with available(self) {
  if self.is_closed() {
    0
  } else {
    1
  }
}

///|
impl Reader with read_all(self) {
  let buffer = @buffer.HeapByteBuf::new(default_buffer_size)
  // 需要 ensure capacity 以及合理扩容策略
  let array : FixedArray[Byte] = FixedArray::make(default_buffer_size, 0)
  let mut read = 1
  while read > 0 {
    read = self.read(array, 0, default_buffer_size)
    if read > 0 {
      buffer.write(array, 0, read)
    }
  }
  buffer as &@buffer.Buffer
}

///|
impl Reader with read_buffer(self, len) {
  let buffer = @buffer.HeapByteBuf::new(len)
  let array : FixedArray[Byte] = FixedArray::make(default_buffer_size, 0)
  let mut toRead = len
  while toRead > 0 {
    let read = self.read(array, 0, @cmp.minimum(toRead, default_buffer_size))
    if read > 0 {
      buffer.write(array, 0, read)
      toRead -= read
    } else {
      break // EOF
    }
  }
  buffer as &@buffer.Buffer
}

///|
impl Reader with read_buffer_to(self, buf) -> Int {
  let mut toRead = buf.writable_bytes()
  let buffer : FixedArray[Byte] = FixedArray::make(default_buffer_size, 0)
  let mut totalRead = 0
  while toRead > 0 {
    let read = self.read(buffer, 0, @cmp.minimum(toRead, default_buffer_size))
    if read <= 0 {
      break // eof
    }
    totalRead += read
    buf.write(buffer, 0, read)
    toRead -= read
  }
  totalRead
}

///|
impl Writer with write_buffer(self, buf) {
  let _buf: FixedArray[Byte] = FixedArray::make(default_buffer_size, 0)
  let mut totalWritten = 0
  while buf.readable_bytes() > 0 {
      let to_write = @cmp.minimum(buf.readable_bytes(), default_buffer_size)
      let read = buf.read(_buf, 0, to_write)
      let written = self.write(_buf, 0, read)
      if written > 0 {
        totalWritten += written
      } else {
        break
      }
  }
  totalWritten

}
