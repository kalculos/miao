///| HTTP Writer that operates on an @io.Writer

///| HTTP Writer for writing HTTP messages
pub struct HttpWriter {
  writer : &@io.Writer
}

///| Create a new HttpWriter from a Writer
pub fn HttpWriter::new(writer : &@io.Writer) -> HttpWriter {
  { writer }
}

///| Write HTTP request to the underlying writer
pub async fn HttpWriter::write_request(
  self : HttpWriter,
  request : HttpRequest
) -> Unit raise {
  // Write request line
  self.write_string(request.method().to_string())
  self.write_string(" ")
  self.write_string(request.uri)
  self.write_string(" ")
  self.write_string(request.version.to_string())
  self.write_string("\r\n")
  
  // Write headers
  for i = 0; i < request.headers.headers.length(); i = i + 1 {
    let (name, value) = request.headers.headers[i]
    self.write_string(name)
    self.write_string(": ")
    self.write_string(value)
    self.write_string("\r\n")
  }
  
  // Empty line after headers
  self.write_string("\r\n")
  
  // Write body
  if request.body.length() > 0 {
    self.write_bytes(request.body)
  }
}

///| Write HTTP response to the underlying writer
pub async fn HttpWriter::write_response(
  self : HttpWriter,
  response : HttpResponse
) -> Unit raise {
  // Write status line
  self.write_string(response.version.to_string())
  self.write_string(" ")
  self.write_string(response.status.code.to_string())
  self.write_string(" ")
  self.write_string(response.status.reason)
  self.write_string("\r\n")
  
  // Write headers
  for i = 0; i < response.headers.headers.length(); i = i + 1 {
    let (name, value) = response.headers.headers[i]
    self.write_string(name)
    self.write_string(": ")
    self.write_string(value)
    self.write_string("\r\n")
  }
  
  // Empty line after headers
  self.write_string("\r\n")
  
  // Write body
  if response.body.length() > 0 {
    self.write_bytes(response.body)
  }
}

///| Write string to the writer
async fn HttpWriter::write_string(self : HttpWriter, s : String) -> Unit {
  // Convert string to UTF-8 bytes
  let len = s.length()
  let arr : FixedArray[Byte] = FixedArray::make(len, 0)
  for i = 0; i < len; i = i + 1 {
    arr[i] = s[i].land(0xFF).to_byte()
  }
  let mut total_written = 0
  while total_written < len {
    let written = self.writer.write(arr, total_written, len - total_written)
    total_written = total_written + written
  }
}

///| Write bytes to the writer
async fn HttpWriter::write_bytes(self : HttpWriter, bytes : Bytes) -> Unit {
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
