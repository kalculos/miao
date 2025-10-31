///|
/// DeflateReader wraps an io.Reader and decompresses DEFLATE data on read.
/// Similar to Java's DeflateInputStream.
pub struct DeflateReader {
  source : &@io.Reader
  bit_reader : BitReaderStream
  priv mut closed : Bool
  priv mut buffer : Array[Byte]
  priv mut finished : Bool
  priv mut window : Array[Byte]  // LZ77 sliding window
}

///|
/// Create a new DeflateReader that reads compressed data from the source.
pub fn DeflateReader::new(source : &@io.Reader) -> DeflateReader {
  DeflateReader::{
    source,
    bit_reader: bit_reader(),
    closed: false,
    buffer: Array::new(),
    finished: false,
    window: Array::new(),
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

  // If stream is finished and buffer is empty, return 0
  if self.finished && self.buffer.length() == 0 {
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

  // Need to decompress more data
  if !self.finished {
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
      ignore(self.bit_reader.feed(Bytes::from_array(input_bytes)))
    }
    
    // Decode DEFLATE blocks
    let decoded = try_decode_block(self)
    if decoded {
      // Recursively call read to return buffered data
      return self.read(dst, off, len)
    }
  }
  
  0
}

///|
/// Try to decode one DEFLATE block from the bit reader.
/// Returns true if data was decoded and buffered, false otherwise.
fn try_decode_block(self : DeflateReader) -> Bool {
  // Read DEFLATE block header (3 bits)
  match self.bit_reader.read_bits(1U) {
    Some(bfinal) => {
      if bfinal == 1U {
        self.finished = true
      }
      
      // Read block type (2 bits)
      match self.bit_reader.read_bits(2U) {
        Some(btype) => {
          match btype {
            0U => decode_stored_block(self) // Stored block
            1U => false // Fixed Huffman (not implemented yet)
            2U => false // Dynamic Huffman (not implemented yet)
            _ => false  // Reserved/invalid
          }
        }
        None => false
      }
    }
    None => false
  }
}

///|
/// Decode a stored (uncompressed) block.
fn decode_stored_block(self : DeflateReader) -> Bool {
  // Align to byte boundary
  self.bit_reader.align_to_byte()
  
  // Read LEN (2 bytes, little-endian)
  match self.bit_reader.take_bytes(2) {
    Some(len_bytes) => {
      let len = len_bytes[0].to_int() | (len_bytes[1].to_int() << 8)
      
      // Read NLEN (2 bytes, little-endian) - we don't verify it for now
      match self.bit_reader.take_bytes(2) {
        Some(_nlen_bytes) => {
          // Read LEN bytes of literal data
          match self.bit_reader.take_bytes(len) {
            Some(data) => {
              // Add data to buffer
              let mut i = 0
              while i < data.length() {
                self.buffer.push(data[i])
                i = i + 1
              }
              true
            }
            None => false
          }
        }
        None => false
      }
    }
    None => false
  }
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
