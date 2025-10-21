///|
pub struct ByteBufReader {
  buffer : &@bytebuf.ByteBuf
  priv mut closed : Bool
}

///|
pub fn ByteBufReader::new(buf : &@bytebuf.ByteBuf) -> ByteBufReader {
  { buffer: buf, closed: false }
}

///|
impl Reader for ByteBufReader with read(self, dst : FixedArray[Byte], off : Int, len : Int) -> Int {
  if self.closed {
    return 0
  }
  let remaining = self.buffer.remaining()
  if remaining == 0 {
    return 0
  }
  let to_read = @cmp.minimum(len, remaining)
  let bytes_read = self.buffer.read(dst, off, to_read)
  bytes_read
}

///|
impl Reader for ByteBufReader with close(self) -> Unit {
  self.closed = true
}

///|
impl Reader for ByteBufReader with is_closed(self) -> Bool {
  self.closed
}

///|
pub(all) struct ByteBufWriter {
  buffer : &@bytebuf.ByteBuf
  priv mut closed : Bool
}

///|
pub fn ByteBufWriter::new(buf : &@bytebuf.ByteBuf) -> ByteBufWriter {
  ByteBufWriter::{ buffer: buf, closed: false }
}

///|
impl Writer for ByteBufWriter with write(self, arr : FixedArray[Byte], off : Int, len : Int) -> Int {
  if self.closed {
    return 0
  }
  let remaining_capacity = self.buffer.capacity()
  if remaining_capacity == 0 {
    return 0
  }
  let to_write = @cmp.minimum(len, remaining_capacity)
  self.buffer.write_array(arr, off, to_write)
  to_write
}

///|
impl Writer for ByteBufWriter with close(self) -> Unit {
  self.closed = true
}

///|
impl Writer for ByteBufWriter with is_closed(self) -> Bool {
  self.closed
}