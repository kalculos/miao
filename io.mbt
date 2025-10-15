///|
pub(open) trait Reader: @io.Reader {
  async read_buffer(Self, len : Int) -> &@bytebuf.ByteBuf = _
  async read_buffer_to(Self, buf : &@bytebuf.ByteBuf) -> Int = _
  async close(Self) -> Unit
  async can_read(Self) -> Bool
}

///|
pub(open) trait Writer: @io.Writer {
  ///| Write a bytebuf into the writer.
  /// Returns: (read, written)
  async write_array(Self, arr : FixedArray[Byte], off : Int, len : Int) -> Int = _
  async write_buffer(Self, buf : &@bytebuf.ByteBuf) -> (Int, Int) = _
  async close(Self) -> Unit
  async can_write(Self) -> Bool
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
