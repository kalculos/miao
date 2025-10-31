///|
/// DeflateWriter wraps an io.Writer and compresses data using DEFLATE on write.
/// Similar to Java's DeflateOutputStream.
pub struct DeflateWriter {
  sink : &@io.Writer
  bit_writer : BitWriter
  priv mut closed : Bool
  priv mut final_written : Bool
}

///|
/// Create a new DeflateWriter that writes compressed data to the sink.
pub fn DeflateWriter::new(sink : &@io.Writer) -> DeflateWriter {
  DeflateWriter::{
    sink,
    bit_writer: bit_writer(),
    closed: false,
    final_written: false,
  }
}

///|
/// Write uncompressed bytes, compressing them before writing to the underlying writer.
/// Returns the number of uncompressed bytes accepted (not the compressed bytes written).
/// Uses DEFLATE stored (uncompressed) blocks for simplicity.
pub impl @io.Writer for DeflateWriter with write(
  self,
  arr : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  if self.closed || len <= 0 {
    return 0
  }

  // Write data as stored (uncompressed) DEFLATE blocks
  // DEFLATE stored block format (RFC 1951):
  // - 3 bits: BFINAL (1 bit) + BTYPE (2 bits, 00 = stored)
  // - Align to byte boundary
  // - 2 bytes: LEN (length of data, little-endian)
  // - 2 bytes: NLEN (one's complement of LEN, little-endian)
  // - LEN bytes: literal data

  // Write block header: BFINAL=0, BTYPE=00 (stored)
  self.bit_writer.write_bits(0U, 1U) // BFINAL = 0 (not final)
  self.bit_writer.write_bits(0U, 2U) // BTYPE = 00 (stored)

  // Align to byte boundary
  self.bit_writer.align_to_byte()

  // Write LEN and NLEN
  let block_len = len.to_uint16()
  let nlen = (0xFFFF - block_len.to_int()).to_uint16()
  self.bit_writer.write_le16(block_len)
  self.bit_writer.write_le16(nlen)

  // Write raw data bytes
  let data_bytes = Array::new()
  let mut i = 0
  while i < len {
    data_bytes.push(arr[off + i])
    i = i + 1
  }
  self.bit_writer.write_raw_bytes(Bytes::from_array(data_bytes))

  // Flush compressed data to sink
  let compressed = self.bit_writer.take_bytes()
  if compressed.length() > 0 {
    let output_buf : FixedArray[Byte] = FixedArray::make(compressed.length(), 0)
    let mut j = 0
    while j < compressed.length() {
      output_buf[j] = compressed[j]
      j = j + 1
    }
    let written = self.sink.write(output_buf, 0, compressed.length())
    if written < compressed.length() {
      // Handle partial writes - return proportional input consumed
      return len * written / compressed.length()
    }
  }
  len
}

///|
/// Close the writer, flushing any remaining data and writing final block.
pub impl @io.Writer for DeflateWriter with close(self) -> Unit {
  if !self.closed {
    self.closed = true

    // Write final empty stored block if not already written
    if !self.final_written {
      // Write block header: BFINAL=1, BTYPE=00 (stored)
      self.bit_writer.write_bits(1U, 1U) // BFINAL = 1 (final block)
      self.bit_writer.write_bits(0U, 2U) // BTYPE = 00 (stored)

      // Align to byte boundary
      self.bit_writer.align_to_byte()

      // Write LEN=0 and NLEN=0xFFFF for empty block
      self.bit_writer.write_le16(0U.to_uint16())
      self.bit_writer.write_le16(0xFFFFU.to_uint16())
      self.final_written = true
    }

    // Flush any remaining bits
    self.bit_writer.align_to_byte()
    let remaining = self.bit_writer.take_bytes()
    if remaining.length() > 0 {
      let output_buf : FixedArray[Byte] = FixedArray::make(
        remaining.length(),
        0,
      )
      let mut i = 0
      while i < remaining.length() {
        output_buf[i] = remaining[i]
        i = i + 1
      }
      ignore(self.sink.write(output_buf, 0, remaining.length()))
    }
    self.sink.close()
  }
}

///|
/// Check if the writer is closed.
pub impl @io.Writer for DeflateWriter with is_closed(self) -> Bool {
  self.closed
}
