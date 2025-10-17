///|
pub(all) struct TeeReader {
  reader : &Reader
  writer : &Writer
}

///|
pub fn TeeReader::new(reader : &Reader, writer : &Writer) -> TeeReader {
  { reader, writer }
}

///|
impl @io.Reader for TeeReader with read(self, buf : FixedArray[Byte], offset~ : Int = 0, max_len~ : Int = buf.length()) -> Int {
  let read_bytes = self.reader.read(buf, offset~, max_len~)
  if read_bytes > 0 {
    // Write the read data to the tee writer
    let write_offset = offset
    let write_max_len = max_len
    let actual_write_len = @cmp.minimum(read_bytes, write_max_len)
    ignore(self.writer.write_once(buf.unsafe_reinterpret_as_bytes(), offset=write_offset, len=actual_write_len))
  }
  read_bytes
}

///|
impl Reader for TeeReader with read_buffer(self, len : Int) -> &@bytebuf.ByteBuf {
  self.reader.read_buffer(len)
}

///|
impl Reader for TeeReader with read_buffer_to(self, buf : &@bytebuf.ByteBuf) -> Int {
  self.reader.read_buffer_to(buf)
}

///|
impl Reader for TeeReader with close(self) -> Unit {
  self.reader.close()
}

///|
impl Reader for TeeReader with can_read(self) -> Bool {
  self.reader.can_read()
}

///| LimitReader is a special reader that closes itself when N<=remaining bytes are read.
/// This does not close the underlying reader.
pub(all) struct LimitedReader {
  reader : &Reader
  mut remaining : Int
}

///|
pub fn LimitedReader::new(reader : &Reader, limit : Int) -> LimitedReader {
  { reader, remaining: limit }
}

///|
impl @io.Reader for LimitedReader with read(self, buf : FixedArray[Byte], offset~ : Int = 0, max_len~ : Int = buf.length() - offset) -> Int {
  if self.remaining <= 0 {
    raise fail("The LimitedReader has exceed its length limit")
  }
  let read_size = @cmp.minimum(max_len, self.remaining)
  let bytes_read = self.reader.read(buf, offset~, max_len=read_size)
  self.remaining -= bytes_read
  bytes_read
}

///|
impl Reader for LimitedReader with read_buffer(self, len : Int) -> &@bytebuf.ByteBuf {
  if self.remaining <= 0 {
    return @bytebuf.make_unpooled_from_bytes(b"") 
  }
  let actual_len = @cmp.minimum(len, self.remaining)
  self.reader.read_buffer(actual_len)
}

///|
impl Reader for LimitedReader with read_buffer_to(self, buf : &@bytebuf.ByteBuf) -> Int {
  if self.remaining <= 0 {
    raise fail("The LimitedReader has exceed its length limit")
  }
  let available_space = buf.capacity()
  let read_size = @cmp.minimum(available_space, self.remaining)
  let read = self.reader.read_exactly(read_size)
  buf.write_bytes(read)
  self.remaining -= read.length()
  read.length()
}

///|
impl Reader for LimitedReader with close(self) -> Unit {
  self.reader.close()
}

///|
impl Reader for LimitedReader with can_read(self) -> Bool {
  self.remaining > 0 && self.reader.can_read()
}

///|
pub(all) struct ComposeReader {
  readers : Array[&Reader]
  mut current_index : Int
}

///|
pub fn ComposeReader::new(readers : Array[&Reader]) -> ComposeReader {
  { readers, current_index: 0 }
}

///|
impl @io.Reader for ComposeReader with read(self, buf : FixedArray[Byte], offset~ : Int = 0, max_len~ : Int = buf.length() - offset) -> Int {
  let mut total_read = 0
  let mut current_offset = offset
  let max_bytes_to_read = max_len
  
  while total_read < max_bytes_to_read && self.current_index < self.readers.length() {
    let reader = self.readers[self.current_index]
    let remaining_space = max_bytes_to_read - total_read
    let bytes_read = reader.read(buf, offset=current_offset, max_len=remaining_space)
    
    if bytes_read > 0 {
      total_read += bytes_read
      current_offset += bytes_read
    } else if bytes_read == 0 {
      // Current reader is exhausted, move to next
      self.current_index += 1
    } else {
      // Error or negative return, propagate it
      return bytes_read
    }
  }
  
  total_read
}

///|
impl Reader for ComposeReader with read_buffer(self, len : Int) -> &@bytebuf.ByteBuf {
  let result_buf = @bytebuf.make_unpooled(len)
  let mut remaining = len
  let mut total_read = 0
  
  while remaining > 0 && self.current_index < self.readers.length() {
    let reader = self.readers[self.current_index]
    let bytes_to_read = @cmp.minimum(remaining, 4096) // Read in chunks
    let temp_buf = reader.read_buffer(bytes_to_read)
    let mut bytes_read = temp_buf.remaining()
    
    if bytes_read > 0 {
      while bytes_read >0 {
        bytes_read -= temp_buf.transfer_to(result_buf, bytes_read)
      }
      total_read += bytes_read
      remaining -= bytes_read
    } else if bytes_read == 0 {
      // Current reader is exhausted, move to next
      self.current_index += 1
    } else {
      // Error, return what we have so far
      break
    }
  }
  
  result_buf
}

///|
impl Reader for ComposeReader with read_buffer_to(self, buf : &@bytebuf.ByteBuf) -> Int {
  let mut total_read = 0
  let target_capacity = buf.capacity()
  
  while total_read < target_capacity && self.current_index < self.readers.length() {
    let reader = self.readers[self.current_index]
    let remaining_space = target_capacity - total_read
    let temp_bytes = reader.read_exactly(@cmp.minimum(remaining_space, 4096))
    
    if temp_bytes.length() > 0 {
      let temp_array = FixedArray::make(temp_bytes.length(), b'0')
      for i = 0; i < temp_bytes.length(); i = i + 1 {
        temp_array[i] = temp_bytes[i]
      }
      buf.write_array(temp_array, 0, temp_bytes.length())
      total_read += temp_bytes.length()
    } else {
      // Current reader is exhausted, move to next
      self.current_index += 1
    }
  }
  
  total_read
}

///|
impl Reader for ComposeReader with close(self) -> Unit {
  for i = 0; i < self.readers.length(); i = i + 1 {
    self.readers[i].close()
  }
}

///|
impl Reader for ComposeReader with can_read(self) -> Bool {
  if self.current_index >= self.readers.length() {
    return false
  }
  // Check if current reader or any remaining reader can read
  for i = self.current_index; i < self.readers.length(); i = i + 1 {
    if self.readers[i].can_read() {
      return true
    }
  }
  false
}


pub struct ByteBufReader {
  buffer: &@bytebuf.ByteBuf
  priv mut closed: Bool
}

///|
pub fn ByteBufReader::new(buf: &@bytebuf.ByteBuf) -> ByteBufReader {
  { buffer: buf, closed: false }
}

///|
impl @io.Reader for ByteBufReader with read(self, buf: FixedArray[Byte], offset~: Int = 0, max_len~: Int = buf.length() - offset) -> Int {
  if self.closed {
    return -1
  }
  let available = self.buffer.remaining()
  if available == 0 {
    return 0
  }
  let to_read = @cmp.minimum(available, max_len)
  let temp =   self.buffer.read_bytes(to_read).unwrap()
  for i = 0; i < temp.length(); i = i + 1 {
    buf[offset + i] = temp[i]
  }
  temp.length()
}

///|
impl Reader for ByteBufReader with read_buffer(self, len: Int) -> &@bytebuf.ByteBuf {
  if self.closed {
    return @bytebuf.make_unpooled_from_bytes(b"")
  }
  let available = self.buffer.remaining()
  let actual_len = @cmp.minimum(available, len)
  let result = @bytebuf.make_unpooled(actual_len)
  ignore(self.buffer.transfer_to(result, actual_len))
  result
}

///|
impl Reader for ByteBufReader with read_buffer_to(self, buf: &@bytebuf.ByteBuf) -> Int {
  if self.closed {
    return -1
  }
  let available = self.buffer.remaining()
  if available == 0 {
    return 0
  }
  let capacity = buf.capacity()
  let to_read = @cmp.minimum(available, capacity)
  self.buffer.transfer_to(buf, to_read)
}

///|
impl Reader for ByteBufReader with close(self) -> Unit {
  self.closed = true
}

///|
impl Reader for ByteBufReader with can_read(self) -> Bool {
  !self.closed && self.buffer.remaining() > 0
}