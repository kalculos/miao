///|
pub(open) trait Reader {
  /// Read a specific amount of bytes at most, to the destinated buffer.
  /// It returns the actual bytes read or 0 if the Reader is closed or drained.
  async read(Self, dst : FixedArray[Byte], off : Int, len : Int) -> Int
  /// Read bytes to a bytebuffer until the reader is drained or closed.
  async read_all(Self) -> &@bytebuf.ByteBuf = _
  async read_buffer(Self, len : Int) -> &@bytebuf.ByteBuf = _
  /// Read (buf.len - off) bytes at most to the buffer.
  async read_buffer_to(Self, off : Int, buf : &@bytebuf.ByteBuf) -> Int = _
  async close(Self) -> Unit
  ///| This also indicates the state of closer
  async is_closed(Self) -> Bool
}

///|
pub(open) trait Writer {
  /// Write a byte array and returns the bytes that we actually write.
  async write(Self, arr : FixedArray[Byte], off : Int, len : Int) -> Int
  /// Write a buffer to the writer. The buffer must support marking & seeking
  /// It returns the bytes actually written. 
  async write_buffer(
    Self,
    off : Int,
    buf : &@bytebuf.ByteBuf,
    increase_reader_index : Bool,
  ) -> Int = _
  async close(Self) -> Unit
  ///| This also indicates the state of closer
  async is_closed(Self) -> Bool
}

///|
impl Reader with read_buffer(self, len) -> &@bytebuf.ByteBuf {
  @bytebuf.make_unpooled_from_bytes(self.read_exactly(len))
}

///|
impl Reader with read_buffer_to(self, buf) -> Int {
  let mut toRead = buf.capacity()
  if toRead == 0 {
    return 0
  }
  let buffer : FixedArray[Byte] = FixedArray::make(4096, 0)
  while toRead > 0 {
    let read = self.read(
      buffer,
      offset=0,
      max_len=@cmp.minimum(buffer.length(), toRead),
    )
    buf.write_array(buffer, 0, read)
    toRead -= read
  } else {
    toRead
  }
}

///|
impl Writer with write_array(self, arr, off, len) -> Int {
  return self.write_once(arr.unsafe_reinterpret_as_bytes(), offset=off, len~)
}

///|
impl Writer with write_buffer(self, buf) -> (Int, Int) {
  let buffer : FixedArray[Byte] = FixedArray::make(4096, 0)
  let mut totalWritten = 0
  let mut totalRead = 0
  let mut read = 1
  outermost~: while read > 0 {
    read = buf.read(buffer, 0, 4096)
    if read < 0 {
      continue
    }
    let mut toWrite = read
    totalRead += read
    while toWrite > 0 {
      let written = self.write_array(buffer, 0, toWrite)
      if written <= 0 {
        break outermost~
      }
      toWrite -= written
      totalWritten += written
    }
  }
  (totalRead, totalWritten)
}
