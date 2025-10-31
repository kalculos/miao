///|
/// DeflateReader wraps an io.Reader and decompresses DEFLATE data on read.
/// Similar to Java's DeflateInputStream.
pub struct DeflateReader {
  source : &@io.Reader
  bit_reader : BitReaderStream
  priv mut closed : Bool
  priv mut buffer : Array[Byte]
}

///|
/// Create a new DeflateReader that reads compressed data from the source.
pub fn DeflateReader::new(source : &@io.Reader) -> DeflateReader {
  DeflateReader::{
    source,
    bit_reader: bit_reader(),
    closed: false,
    buffer: Array::new(),
  }
}

///|
/// Read decompressed bytes into the destination buffer.
/// Returns the number of bytes actually read, or 0 if EOF or closed.
pub impl @io.Reader for DeflateReader with read(
  self,
  dst : FixedArray[Byte],
  off : Int,
  len : Int
) -> Int {
  if self.closed || len <= 0 {
    return 0
  }

  // If we have buffered decompressed data, return it first
  if self.buffer.length() > 0 {
    let to_copy = @cmp.minimum(len, self.buffer.length())
    let mut i = 0
    while i < to_copy {
      dst[off + i] = self.buffer[i]
      i = i + 1
    }
    // Remove copied bytes from buffer
    let remaining = Array::new()
    let mut j = to_copy
    while j < self.buffer.length() {
      remaining.push(self.buffer[j])
      j = j + 1
    }
    self.buffer = remaining
    return to_copy
  }

  // Try to read more compressed data from source and feed to bit reader
  let input_buf : FixedArray[Byte] = FixedArray::make(4096, 0)
  let bytes_read = self.source.read(input_buf, 0, 4096)
  
  if bytes_read > 0 {
    // Convert FixedArray to Bytes and feed to bit reader
    let input_bytes = Array::new()
    let mut idx = 0
    while idx < bytes_read {
      input_bytes.push(input_buf[idx])
      idx = idx + 1
    }
    let fed = self.bit_reader.feed(Bytes::from_array(input_bytes))
    
    // TODO: Implement actual DEFLATE decompression here
    // For now, we just pass through the data as-is (placeholder)
    // When full DEFLATE decoder is implemented, this should:
    // 1. Decode DEFLATE blocks using Huffman tables
    // 2. Handle LZ77 back-references
    // 3. Manage sliding window
    
    // Placeholder: copy some bytes from bit reader to output
    match self.bit_reader.take_bytes(@cmp.minimum(len, fed)) {
      Some(bytes) => {
        let mut i = 0
        let copy_len = @cmp.minimum(len, bytes.length())
        while i < copy_len {
          dst[off + i] = bytes[i]
          i = i + 1
        }
        return copy_len
      }
      None => return 0
    }
  }
  
  0
}

///|
/// Close the reader and release resources.
pub impl @io.Reader for DeflateReader with close(self) -> Unit {
  self.closed = true
  self.source.close()
}

///|
/// Check if the reader is closed.
pub impl @io.Reader for DeflateReader with is_closed(self) -> Bool {
  self.closed
}
