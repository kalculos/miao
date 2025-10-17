///|
pub(all) struct DiscardWriter {}

///|
pub fn DiscardWriter::new() -> DiscardWriter {
  DiscardWriter::{  }
}

///|
impl @io.Writer for DiscardWriter with write_once(
  self,
  _bytes : Bytes,
  offset~ : Int,
  len~ : Int,
) -> Int {
  // Simply return the length to indicate all bytes were "written" (discarded)
  len
}

///|
impl Writer for DiscardWriter with write_array(
  self,
  _arr : FixedArray[Byte],
  _off : Int,
  len : Int,
) -> Int {
  // Simply return the length to indicate all bytes were "written" (discarded)
  len
}

///|
impl Writer for DiscardWriter with write_buffer(self, _buf : &@bytebuf.ByteBuf) -> (
  Int,
  Int,
) {
  // Return (read, written) - read all from buffer, "wrote" all to discard
  let remaining = _buf.remaining()
  let _ = _buf.read_bytes(remaining) // TODO: skipN
  (_buf.capacity(), remaining)
}

///|
impl Writer for DiscardWriter with close(self) -> Unit {
  // Nothing to close for a discard writer
  ()
}

///|
impl Writer for DiscardWriter with can_write(self) -> Bool {
  // Always can write to discard
  true
}

///|
pub(all) struct DuplexWriter {
  writer1 : &Writer
  writer2 : &Writer
}

///|
pub fn DuplexWriter::new(writer1 : &Writer, writer2 : &Writer) -> DuplexWriter {
  { writer1, writer2 }
}

///|
impl @io.Writer for DuplexWriter with write_once(
  self,
  bytes : Bytes,
  offset~ : Int,
  len~ : Int,
) -> Int {
  // Write to both writers and return the minimum bytes written
  let written1 = self.writer1.write_once(bytes, offset~, len~)
  let written2 = self.writer2.write_once(bytes, offset~, len~)
  @cmp.minimum(written1, written2)
}

///|
impl Writer for DuplexWriter with write_array(
  self,
  arr : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  // Write to both writers and return the minimum bytes written
  let written1 = self.writer1.write_array(arr, off, len)
  let written2 = self.writer2.write_array(arr, off, len)
  @cmp.minimum(written1, written2)
}

///|
impl Writer for DuplexWriter with write_buffer(self, buf : &@bytebuf.ByteBuf) -> (
  Int,
  Int,
) {
  // Create a copy of the buffer to read from both writers
  let buf_copy = @bytebuf.make_unpooled(buf.capacity())
  let original_remaining = buf.remaining()

  // First, copy all data from original buffer to our copy
  let temp_array = FixedArray::make(4096, b'0')
  let mut total_copied = 0
  let mut read = 1
  while read > 0 {
    read = buf.read(temp_array, 0, 4096)
    if read > 0 {
      buf_copy.write_array(temp_array, 0, read)
      total_copied += read
    }
  }

  // Reset position for both buffers
  buf.reset()
  buf_copy.reset()

  // Write to both writers
  let (read1, written1) = self.writer1.write_buffer(buf)
  let (read2, written2) = self.writer2.write_buffer(buf_copy)

  // Return minimum values
  (@cmp.minimum(read1, read2), @cmp.minimum(written1, written2))
}

///|
impl Writer for DuplexWriter with close(self) -> Unit {
  // Close both writers
  self.writer1.close()
  self.writer2.close()
}

///|
impl Writer for DuplexWriter with can_write(self) -> Bool {
  // Can write if both writers can write
  self.writer1.can_write() && self.writer2.can_write()
}

///|
pub(all) struct ByteBufWriter {
  buffer : &@bytebuf.ByteBuf
  priv mut closed: Bool
}

///|
pub fn ByteBufWriter::new(buf : &@bytebuf.ByteBuf) -> ByteBufWriter {
  ByteBufWriter::{ buffer: buf, closed: false }
}

///|
impl @io.Writer for ByteBufWriter with write_once(
  self,
  bytes : Bytes,
  offset~ : Int,
  len~ : Int,
) -> Int {
  self.buffer.write_bytes(bytes[offset:len].to_bytes()) //todo optimization
  len
}

///|
impl Writer for ByteBufWriter with write_array(
  self,
  arr : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  self.buffer.write_array(arr, off, len)
  len
}

///|
impl Writer for ByteBufWriter with write_buffer(self, buf : &@bytebuf.ByteBuf) -> (
  Int,
  Int,
) {
  let a = buf.transfer_to(self.buffer, buf.remaining())
  (a, a)
}

///|
impl Writer for ByteBufWriter with close(self) -> Unit {
  // Nothing to close for a buffer writer
  guard !self.closed
  self.closed = true
}

///|
impl Writer for ByteBufWriter with can_write(self) -> Bool {
  true
}
