///| HTTP Request Parser

///| Parse HTTP request from buffer
pub async fn parse_request(buffer : &@buffer.Buffer) -> HttpRequest raise {
  // Read request line
  let request_line = read_line(buffer)
  let (http_method, uri, version) = parse_request_line(request_line)
  
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
  
  { http_method, uri, version, headers, body }
}

///| Parse request line (e.g., "GET /path HTTP/1.1")
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

///| Parse HTTP headers
fn parse_headers(buffer : &@buffer.Buffer) -> HttpHeaders raise {
  let headers = HttpHeaders::new()
  
  while true {
    let line = read_line(buffer)
    if line.is_empty() {
      break
    }
    
    // Parse header: "Name: Value"
    let colon_pos = line.index_of(":")
    match colon_pos {
      Some(pos) => {
        let name = line.substring(start=0, end=pos).trim(chars=" \t\r\n").to_string()
        let value = line.substring(start=pos + 1).trim(chars=" \t\r\n").to_string()
        headers.add(name, value)
      }
      None => raise fail("Invalid header line: " + line)
    }
  }
  
  headers
}

///| Read a line from buffer (until \r\n or \n)
fn read_line(buffer : &@buffer.Buffer) -> String raise {
  let line_bytes = Array::new()
  let mut prev_byte : Byte = 0
  
  while buffer.readable_bytes() > 0 {
    let byte = buffer.read_byte()
    
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
  
  // Convert bytes to string
  let arr : FixedArray[Byte] = FixedArray::make(line_bytes.length(), 0)
  for i = 0; i < line_bytes.length(); i = i + 1 {
    arr[i] = line_bytes[i]
  }
  bytes_to_string(Bytes::from_array(arr))
}

///| Read specific number of bytes from buffer
fn read_bytes(buffer : &@buffer.Buffer, length : Int) -> Bytes raise {
  let arr : FixedArray[Byte] = FixedArray::make(length, 0)
  let read = buffer.read(arr, 0, length)
  if read != length {
    raise fail("Expected " + length.to_string() + " bytes, got " + read.to_string())
  }
  Bytes::from_array(arr)
}

///| Convert Bytes to String (UTF-8)
fn bytes_to_string(bytes : Bytes) -> String {
  // Use builtin Bytes.to_string() which properly handles UTF-8
  bytes.to_string()
}

///| Helper to find index of character in string
fn String::index_of(self : String, needle : String) -> Int? {
  let len = self.length()
  let needle_len = needle.length()
  if needle_len > len {
    return None
  }
  
  for i = 0; i <= len - needle_len; i = i + 1 {
    let mut match_found = true
    for j = 0; j < needle_len; j = j + 1 {
      if self[i + j] != needle[j] {
        match_found = false
        break
      }
    }
    if match_found {
      return Some(i)
    }
  }
  None
}

///| Helper to convert string to lowercase (shadows built-in to_lower)
fn String::to_lower(self : String) -> String {
  let mut result = ""
  for i = 0; i < self.length(); i = i + 1 {
    let c = self[i]
    if c >= 'A' && c <= 'Z' {
      result = result + (c + 32).unsafe_to_char().to_string()
    } else {
      result = result + c.to_string()
    }
  }
  result
}

///| Parse integer from string
fn String::parse_int(self : String) -> Int? {
  let mut result = 0
  let mut sign = 1
  let mut start = 0
  
  if self.length() == 0 {
    return None
  }
  
  if self[0] == '-' {
    sign = -1
    start = 1
  } else if self[0] == '+' {
    start = 1
  }
  
  if start >= self.length() {
    return None
  }
  
  for i = start; i < self.length(); i = i + 1 {
    let c = self[i]
    if c >= '0' && c <= '9' {
      result = result * 10 + (c - '0')
    } else {
      return None
    }
  }
  
  Some(result * sign)
}
