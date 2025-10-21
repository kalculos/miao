///|
pub(open) trait Reader {
  /// Read a specific amount of bytes at most, to the destinated buffer.
  /// It returns the actual bytes read or 0 if the Reader is closed or drained.
  async read(Self, dst : FixedArray[Byte], off : Int, len : Int) -> Int
  /// Read bytes to a bytebuffer until the reader is drained or closed.
  async read_all(Self) -> &@bytebuf.ByteBuf = _
  async read_buffer(Self, len : Int) -> &@bytebuf.ByteBuf = _
  /// Read (buf.len - off) bytes at most to the buffer.
  async read_buffer_to(Self, buf : &@bytebuf.ByteBuf) -> Int = _
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
    buf : &@bytebuf.ByteBuf, // a sliced buffer can be used to control if reader index should inc. Or also supports skipN
  ) -> Int = _
  async close(Self) -> Unit
  ///| This also indicates the state of closer
  async is_closed(Self) -> Bool
}

///|
impl Reader with read_all(self) {
  let buffer = @bytebuf.make_unpooled(1024)
  // 需要 ensure capacity 以及合理扩容策略
  let array : FixedArray[Byte] = FixedArray::make(1024, 0)
  let mut read = 1
  while read > 0 {
    read = self.read(array, 0, 1024)
    buffer.write_array(array, 0, read)
  }
  buffer
}

///|
impl Reader with read_buffer(self, len) {
  let array : FixedArray[Byte] = FixedArray::make(len, 0)
  let mut toRead = len
  while toRead > 0 {
    let read = self.read(array, len - toRead, toRead)
    if read > 0 {
      toRead -= read
    } else {
      break // EOF
    }
  }
  @bytebuf.make_unpooled_from_array(Array::from_fixed_array(array)) // data 需要是一个 FixedArray
}

///|
impl Reader with read_buffer_to(self, buf) -> Int {
  let toRead = buf.capacity()
  let buffer : FixedArray[Byte] = FixedArray::make(1024, 0)
  let mut totalRead = 0
  while toRead > 0 {
    let read = self.read(buffer, 0, @cmp.minimum(toRead, 1024))
    if read <= 0 {
      break // eof
    }
    totalRead += read
    buf.write_array(buffer, 0, read)
  }
  totalRead
}

///|
impl Writer with write_buffer(self, buf) {
  let _buf: FixedArray[Byte] = FixedArray::make(1, 0)
  let mut totalWritten = 0
  while buf.remaining() >0 {
      let written = self.write(_buf, 0, buf.read(_buf, 0 ,1))
      if written > 0 {
        totalWritten += written
        continue
      }
      break
  }
  totalWritten

}
