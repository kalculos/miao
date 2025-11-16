///| HTTP Request Parser

///|
/// HTTP Reader that operates on an @io.Reader
pub struct HttpReader {
  reader : &@io.Reader
}

///|
/// Create a new HttpReader from a Reader
pub fn HttpReader::new(reader : &@io.Reader) -> HttpReader {
  { reader, }
}

///|
/// Read HTTP request from the underlying reader
pub async fn HttpReader::read_request(self : HttpReader) -> HttpRequest {
  // Read request line
  let request_line = self.read_line()
  let (http_method, uri, version) = parse_request_line(request_line)

  // Parse headers
  let headers = self.read_headers()

  // Create content reader if Content-Length is present
  let content_reader = headers
    .get("Content-Length")
    .map(length_str => {
      let length = @strconv.parse_int(length_str)
      guard length > 0 else {
        raise fail("Invalid HTTP Content-Length: \{length}")
      }
      HttpContentReader::new(self.reader, length)
    })
  { http_method, uri, version, headers, content_reader }
}

///|
/// Read HTTP response from the underlying reader
pub async fn HttpReader::read_response(self : HttpReader) -> HttpResponse {
  // Read status line
  let status_line = self.read_line()
  let (version, status) = parse_status_line(status_line)

  // Parse headers
  let headers = self.read_headers()

  // Create content reader if Content-Length is present
  let content_reader = headers
    .get("Content-Length")
    .map(length_str => {
      let length = @strconv.parse_int(length_str)
      guard length > 0 else {
        raise fail("Invalid HTTP Content-Length: \{length}")
      }
      HttpContentReader::new(self.reader, length)
    })
  { version, status, headers, content_reader }
}

///|
/// Parse request line (e.g., "GET /path HTTP/1.1")
fn parse_request_line(line : String) -> (HttpMethod, String, HttpVersion) raise {
  let parts = line.split(" ").collect()
  if parts.length() != 3 {
    raise fail("Invalid request line: " + line)
  }
  let http_method = HttpMethod::from_string(parts[0].to_string())
  let uri = parts[1].to_string()
  let version = HttpVersion::from_string(parts[2].to_string())
  (http_method, uri, version)
}

///|
/// Parse status line (e.g., "HTTP/1.1 200 OK")
fn parse_status_line(line : String) -> (HttpVersion, HttpStatus) raise {
  let parts = line.split(" ").collect()
  if parts.length() < 2 {
    raise fail("Invalid status line: " + line)
  }
  let version = HttpVersion::from_string(parts[0].to_string())
  let code_str = parts[1].to_string()
  let code = @strconv.parse_int(code_str)
  let reason = if parts.length() > 2 {
    // Join remaining parts as reason phrase
    let mut r = parts[2].to_string()
    for i = 3; i < parts.length(); i = i + 1 {
      r = r + " " + parts[i].to_string()
    }
    r
  } else {
    ""
  }
  (version, HttpStatus::new(code, reason))
}

///|
/// Read HTTP headers from the reader
async fn HttpReader::read_headers(self : HttpReader) -> HttpHeaders {
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
        let name = line[0:pos]
          .trim(chars=" \t\r\n")
          .to_string()
        let value = line[pos + 1:]
          .trim(chars=" \t\r\n")
          .to_string()
        headers.add(name, value)
      }
      None => raise fail("Invalid header line: " + line)
    }
  }
  headers
}

///|
/// Read a line from the reader (until \r\n or \n)
async fn HttpReader::read_line(self : HttpReader) -> String {
  let line_bytes = Array::new()
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
      // Remove the \r we added
      if line_bytes.length() > 0 {
        line_bytes.pop() |> ignore
      }
      break
    }
    // Check for \n only
    if byte == b'\n' {
      break
    }
    line_bytes.push(byte)
    prev_byte = byte
  }

  // Convert bytes to string using UTF-8 decoding
  let arr : FixedArray[Byte] = FixedArray::make(line_bytes.length(), 0)
  for i = 0; i < line_bytes.length(); i = i + 1 {
    arr[i] = line_bytes[i]
  }
  @encoding/utf8.decode(Bytes::from_array(arr))
}