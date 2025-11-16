///| Chunked Transfer Encoding Support

///|
/// Reader for chunked transfer encoding
pub struct HttpChunkedReader {
  reader : &@io.Reader
  mut current_chunk_remaining : Int
  mut finished : Bool
  mut trailer_headers : HttpHeaders?
}

///|
/// Create a new HttpChunkedReader
pub fn HttpChunkedReader::new(reader : &@io.Reader) -> HttpChunkedReader {
  { reader, current_chunk_remaining: 0, finished: false, trailer_headers: None }
}

///|
/// Read all remaining content from chunked encoding
pub async fn HttpChunkedReader::read_all(
  self : HttpChunkedReader,
) -> &@buffer.Buffer {
  let result = @buffer.HeapByteBuf::new(4096)
  while not(self.finished) {
    let chunk = self.read_chunk()
    chunk.transfer_to(result)
  }
  result
}

///|
/// Read the next chunk
async fn HttpChunkedReader::read_chunk(
  self : HttpChunkedReader,
) -> &@buffer.Buffer {
  if self.finished {
    return @buffer.HeapByteBuf::new(0)
  }

  // If we have remaining bytes in current chunk, read them
  if self.current_chunk_remaining > 0 {
    return self.read_from_current_chunk(self.current_chunk_remaining)
  }

  // Read chunk size line
  let size_line = self.read_line()

  // Parse chunk size (hex number, possibly with extensions)
  let chunk_size = parse_chunk_size(size_line)
  if chunk_size == 0 {
    // Last chunk, read trailer headers
    self.finished = true
    self.trailer_headers = Some(self.read_trailer_headers())
    return @buffer.HeapByteBuf::new(0)
  }

  // Read the chunk data
  self.current_chunk_remaining = chunk_size
  let data = self.read_from_current_chunk(chunk_size)

  // Read trailing CRLF after chunk data
  self.read_line() |> ignore
  data
}

///|
/// Read up to n bytes from the current chunk
async fn HttpChunkedReader::read_from_current_chunk(
  self : HttpChunkedReader,
  n : Int,
) -> &@buffer.Buffer {
  let to_read = if n < self.current_chunk_remaining {
    n
  } else {
    self.current_chunk_remaining
  }
  if to_read <= 0 {
    return @buffer.HeapByteBuf::new(0)
  }
  let buffer = self.reader.read_buffer(to_read)
  self.current_chunk_remaining = self.current_chunk_remaining -
    buffer.readable_bytes()
  buffer
}

///|
/// Read a line from the reader (until \r\n or \n)
async fn HttpChunkedReader::read_line(self : HttpChunkedReader) -> String {
  let line_bytes = @buffer.HeapByteBuf::new(128)
  let mut prev_byte : Byte = 0
  let buffer : FixedArray[Byte] = FixedArray::make(1, 0)
  while true {
    let read = self.reader.read(buffer, 0, 1)
    if read == 0 {
      break // EOF
    }
    let byte = buffer[0]

    // Check for \r\n
    if prev_byte == b'\r' && byte == b'\n' {
      // Remove the \r we added - skip back one byte
      if line_bytes.readable_bytes() > 0 {
        // We need to remove the last written byte
        // Since we can't go back, we'll reconstruct without the last byte
        let temp = line_bytes.to_bytes()
        if temp.length() > 0 {
          line_bytes.clear()
          let arr = temp.to_fixedarray()
          line_bytes.write(arr, 0, temp.length() - 1) |> ignore
        }
      }
      break
    }
    // Check for \n only
    if byte == b'\n' {
      break
    }
    line_bytes.write_byte(byte)
    prev_byte = byte
  }

  // Convert bytes to string using UTF-8 decoding
  @encoding/utf8.decode(line_bytes.to_bytes())
}

///|
/// Read trailer headers after the last chunk
async fn HttpChunkedReader::read_trailer_headers(
  self : HttpChunkedReader,
) -> HttpHeaders {
  let headers = HttpHeaders::new()
  while true {
    let line = self.read_line()
    if line.is_empty() {
      break
    }

    // Parse header: "Name: Value"
    let colon_pos = line.find(":")
    match colon_pos {
      Some(pos) => {
        let name = line[0:pos].trim(chars=" \t\r\n").to_string()
        let value = line[pos + 1:].trim(chars=" \t\r\n").to_string()
        headers.add(name, value)
      }
      None => raise fail("Invalid trailer header line: " + line)
    }
  }
  headers
}

///|
/// Get trailer headers (available after reading all chunks)
pub fn HttpChunkedReader::trailer_headers(
  self : HttpChunkedReader,
) -> HttpHeaders? {
  self.trailer_headers
}

///|
/// Check if finished reading all chunks
pub fn HttpChunkedReader::is_finished(self : HttpChunkedReader) -> Bool {
  self.finished
}

///|
/// Parse chunk size from chunk size line
fn parse_chunk_size(line : String) -> Int raise {
  // Chunk size line format: "size[;extensions]"
  // We ignore extensions for now
  let size_str = match line.find(";") {
    Some(pos) => line[0:pos].to_string()
    None => line
  }
  let trimmed = size_str.trim(chars=" \t\r\n").to_string()

  // Parse hex number
  parse_hex_int(trimmed)
}

///|
/// Parse a hexadecimal integer string
fn parse_hex_int(hex : String) -> Int raise {
  let mut result = 0
  for ch in hex {
    result = result * 16
    match ch {
      '0' => result = result + 0
      '1' => result = result + 1
      '2' => result = result + 2
      '3' => result = result + 3
      '4' => result = result + 4
      '5' => result = result + 5
      '6' => result = result + 6
      '7' => result = result + 7
      '8' => result = result + 8
      '9' => result = result + 9
      'a' | 'A' => result = result + 10
      'b' | 'B' => result = result + 11
      'c' | 'C' => result = result + 12
      'd' | 'D' => result = result + 13
      'e' | 'E' => result = result + 14
      'f' | 'F' => result = result + 15
      _ => raise fail("Invalid hex character: " + Char::to_string(ch))
    }
  }
  result
}

///|
/// Writer for chunked transfer encoding
pub struct HttpChunkedWriter {
  writer : &@io.Writer
}

///|
/// Create a new HttpChunkedWriter
pub fn HttpChunkedWriter::new(writer : &@io.Writer) -> HttpChunkedWriter {
  { writer, }
}

///|
/// Write a chunk of data
pub async fn HttpChunkedWriter::write_chunk(
  self : HttpChunkedWriter,
  data : &@buffer.Buffer,
) -> Unit {
  if data.readable_bytes() == 0 {
    return
  }

  // Write chunk size in hex
  self.write_string(data.readable_bytes().to_hex_string())
  self.write_string("\r\n")

  // Write chunk data
  self.write_buffer(data)
  self.write_string("\r\n")
}

///|
/// Write the final chunk (size 0) and optional trailer headers
pub async fn HttpChunkedWriter::write_final_chunk(
  self : HttpChunkedWriter,
  trailer_headers : HttpHeaders?,
) -> Unit {
  // Write final chunk size
  self.write_string("0\r\n")

  // Write trailer headers if present
  match trailer_headers {
    Some(headers) =>
      for i = 0; i < headers.headers.length(); i = i + 1 {
        let (name, value) = headers.headers[i]
        self.write_string(name)
        self.write_string(": ")
        self.write_string(value)
        self.write_string("\r\n")
      }
    None => ()
  }

  // Final CRLF
  self.write_string("\r\n")
}

///|
/// Write string to the writer using UTF-8 encoding
async fn HttpChunkedWriter::write_string(
  self : HttpChunkedWriter,
  s : String,
) -> Unit {
  let bytes = @encoding/utf8.encode(s)
  let buffer = @buffer.HeapByteBuf::wrapped_bytes(bytes)
  self.write_buffer(buffer)
}

///|
/// Write buffer to the writer
async fn HttpChunkedWriter::write_buffer(
  self : HttpChunkedWriter,
  buffer : &@buffer.Buffer,
) -> Unit {
  self.writer.write_buffer(buffer) |> ignore
}

///|
/// Convert integer to hex string
fn Int::to_hex_string(self : Int) -> String {
  if self == 0 {
    return "0"
  }
  let mut n = self
  let digits = Array::new()
  while n > 0 {
    let digit = n % 16
    let ch = match digit {
      0 => '0'
      1 => '1'
      2 => '2'
      3 => '3'
      4 => '4'
      5 => '5'
      6 => '6'
      7 => '7'
      8 => '8'
      9 => '9'
      10 => 'A'
      11 => 'B'
      12 => 'C'
      13 => 'D'
      14 => 'E'
      15 => 'F'
      _ => '0'
    }
    digits.push(ch)
    n = n / 16
  }

  // Reverse the digits and build string
  let mut result = ""
  for i = digits.length() - 1; i >= 0; i = i - 1 {
    result = result + Char::to_string(digits[i])
  }
  result
}
