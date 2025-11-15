///|
pub struct ByteBufReader {
  buffer : &@buffer.Buffer
  priv mut closed : Bool
}

///|
pub fn ByteBufReader::new(buf : &@buffer.Buffer) -> ByteBufReader {
  { buffer: buf, closed: false }
}

///|
pub impl Reader for ByteBufReader with read(
  self,
  dst : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  if self.closed {
    return 0
  }
  let remaining = self.buffer.readable_bytes()
  if remaining == 0 {
    return 0
  }
  let to_read = @cmp.minimum(len, remaining)
  let bytes_read = self.buffer.read(dst, off, to_read)
  bytes_read
}

///|
pub impl Reader for ByteBufReader with close(self) -> Unit {
  self.closed = true
}

///|
pub impl Reader for ByteBufReader with is_closed(self) -> Bool {
  self.closed
}

///|
pub(all) struct ByteBufWriter {
  buffer : &@buffer.Buffer
  priv mut closed : Bool
}

///|
pub fn ByteBufWriter::new(buf : &@buffer.Buffer) -> ByteBufWriter {
  ByteBufWriter::{ buffer: buf, closed: false }
}

///|
pub impl Writer for ByteBufWriter with write(
  self,
  arr : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  if self.closed {
    return 0
  }
  let remaining_capacity = self.buffer.writable_bytes()
  if remaining_capacity == 0 {
    return 0
  }
  let to_write = @cmp.minimum(len, remaining_capacity)
  self.buffer.write(arr, off, to_write)
}

///|
pub impl Writer for ByteBufWriter with close(self) -> Unit {
  self.closed = true
}

///|
pub impl Writer for ByteBufWriter with is_closed(self) -> Bool {
  self.closed
}
