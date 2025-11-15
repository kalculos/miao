///| HTTP Response Parser and Serializer

///| Parse HTTP response from buffer
pub async fn parse_response(buffer : &@buffer.Buffer) -> HttpResponse raise {
  // Read status line
  let status_line = read_line(buffer)
  let (version, status) = parse_status_line(status_line)
  
  // Parse headers
  let headers = parse_headers(buffer)
  
  // Parse body based on Content-Length
  let body = match headers.get("Content-Length") {
    Some(length_str) => {
      let length = length_str.parse_int()
      match length {
        Some(len) => {
          if len > 0 {
            read_bytes(buffer, len)
          } else {
            b""
          }
        }
        None => raise fail("Invalid Content-Length: " + length_str)
      }
    }
    None => b""
  }
  
  { version, status, headers, body }
}

///| Parse status line (e.g., "HTTP/1.1 200 OK")
fn parse_status_line(line : String) -> (HttpVersion, HttpStatus) raise {
  let parts = line.split(" ").collect()
  if parts.length() < 2 {
    raise fail("Invalid status line: " + line)
  }
  
  let version = HttpVersion::from_string(parts[0].to_string())
  let code_str = parts[1].to_string()
  let code = code_str.parse_int()
  
  match code {
    Some(c) => {
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
      (version, HttpStatus::new(c, reason))
    }
    None => raise fail("Invalid status code: " + code_str)
  }
}

///| Serialize HTTP request to buffer
pub async fn serialize_request(
  request : HttpRequest,
  buffer : &@buffer.Buffer
) -> Unit {
  // Write request line
  write_string(buffer, request.method().to_string())
  write_string(buffer, " ")
  write_string(buffer, request.uri)
  write_string(buffer, " ")
  write_string(buffer, request.version.to_string())
  write_string(buffer, "\r\n")
  
  // Write headers
  for i = 0; i < request.headers.headers.length(); i = i + 1 {
    let (name, value) = request.headers.headers[i]
    write_string(buffer, name)
    write_string(buffer, ": ")
    write_string(buffer, value)
    write_string(buffer, "\r\n")
  }
  
  // Empty line after headers
  write_string(buffer, "\r\n")
  
  // Write body
  if request.body.length() > 0 {
    write_bytes(buffer, request.body)
  }
}

///| Serialize HTTP response to buffer
pub async fn serialize_response(
  response : HttpResponse,
  buffer : &@buffer.Buffer
) -> Unit {
  // Write status line
  write_string(buffer, response.version.to_string())
  write_string(buffer, " ")
  write_string(buffer, response.status.code.to_string())
  write_string(buffer, " ")
  write_string(buffer, response.status.reason)
  write_string(buffer, "\r\n")
  
  // Write headers
  for i = 0; i < response.headers.headers.length(); i = i + 1 {
    let (name, value) = response.headers.headers[i]
    write_string(buffer, name)
    write_string(buffer, ": ")
    write_string(buffer, value)
    write_string(buffer, "\r\n")
  }
  
  // Empty line after headers
  write_string(buffer, "\r\n")
  
  // Write body
  if response.body.length() > 0 {
    write_bytes(buffer, response.body)
  }
}

///| Write string to buffer
fn write_string(buffer : &@buffer.Buffer, s : String) -> Unit {
  let bytes = String::to_bytes(s)
  write_bytes(buffer, bytes)
}

///| Write bytes to buffer
fn write_bytes(buffer : &@buffer.Buffer, bytes : Bytes) -> Unit {
  let len = bytes.length()
  let arr : FixedArray[Byte] = FixedArray::make(len, 0)
  for i = 0; i < len; i = i + 1 {
    arr[i] = bytes[i]
  }
  buffer.write(arr, 0, len) |> ignore
}
