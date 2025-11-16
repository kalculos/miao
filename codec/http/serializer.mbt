///| HTTP Writer that operates on an @io.Writer

///|
/// HTTP Writer for writing HTTP messages
pub struct HttpWriter {
  writer : &@io.Writer
}

///|
/// Create a new HttpWriter from a Writer
pub fn HttpWriter::new(writer : &@io.Writer) -> HttpWriter {
  { writer, }
}

///|
/// Helper: write headers and a separating empty line
async fn HttpWriter::write_headers(
  self : HttpWriter,
  headers : HttpHeaders,
) -> Unit {
  for i = 0; i < headers.headers.length(); i = i + 1 {
    let (name, value) = headers.headers[i]
    self.write_string(name)
    self.write_string(": ")
    self.write_string(value)
    self.write_string("\r\n")
  }
  // empty line after headers
  self.write_string("\r\n")
}

///|
/// Write HTTP request to the underlying writer (delegates to helpers)
pub async fn HttpWriter::write_request(
  self : HttpWriter,
  request : HttpRequest,
  body : &@buffer.Buffer,
) -> Unit {
  // Request line
  self.write_string(request.method().to_string())
  self.write_string(" ")
  self.write_string(request.uri)
  self.write_string(" ")
  self.write_string(request.version.to_string())
  self.write_string("\r\n")

  // Headers and body using helpers
  self.write_headers(request.headers)
  self.writer.write_buffer(body) |> ignore
}

///|
/// Write HTTP response to the underlying writer (delegates to helpers)
pub async fn HttpWriter::write_response(
  self : HttpWriter,
  response : HttpResponse,
  body : &@buffer.Buffer,
) -> Unit {
  // Status line
  self.write_string(response.version.to_string())
  self.write_string(" ")
  self.write_string(response.status.code.to_string())
  self.write_string(" ")
  self.write_string(response.status.reason)
  self.write_string("\r\n")

  // Headers and body using helpers
  self.write_headers(response.headers)
  self.writer.write_buffer(body) |> ignore
}

///|
/// Write string to the writer using UTF-8 encoding
async fn HttpWriter::write_string(self : HttpWriter, s : String) -> Unit {
  let bytes = @encoding/utf8.encode(s)
  let len = bytes.length()
  let arr : FixedArray[Byte] = FixedArray::make(len, 0)
  for i = 0; i < len; i = i + 1 {
    arr[i] = bytes[i]
  }
  let mut total_written = 0
  while total_written < len {
    let written = self.writer.write(arr, total_written, len - total_written)
    total_written = total_written + written
  }
}

///|
/// Write buffer to the writer
async fn HttpWriter::write_buffer(
  self : HttpWriter,
  buffer : &@buffer.Buffer,
) -> Unit {
  self.writer.write_buffer(buffer) |> ignore
}

///|
/// Implement @io.Writer for HttpWriter by delegating to underlying writer
pub impl @io.Writer for HttpWriter with write(self, arr, off, len) {
  self.writer.write(arr, off, len)
}

///|
pub impl @io.Writer for HttpWriter with close(self) {
  self.writer.close()
}

///|
pub impl @io.Writer for HttpWriter with is_closed(self) {
  self.writer.is_closed()
}
