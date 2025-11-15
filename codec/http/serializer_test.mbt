///| Tests for HTTP response parser and serializer

///| Helper to write UTF-8 string to buffer
fn write_utf8_string_serializer(buffer : &@buffer.Buffer, s : String) -> Unit {
  let len = s.length()
  let arr : FixedArray[Byte] = FixedArray::make(len, 0)
  for i = 0; i < len; i = i + 1 {
    arr[i] = s[i].land(0xFF).to_byte()
  }
  buffer.write(arr, 0, len) |> ignore
}

///| Test parsing a simple 200 OK response
async test "parse_response parses 200 OK response" {
  let response_str = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: 13\r\n\r\nHello, World!"
  let buffer = @buffer.HeapByteBuf::new(1024)
  write_utf8_string_serializer(buffer as &@buffer.Buffer, response_str)
  let response = try {
    parse_response(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
    }
  }
  inspect(response.version, content="HTTP_1_1")
  inspect(response.status.code, content="200")
  inspect(response.status.reason, content="OK")
  inspect(response.headers.get("Content-Type"), content="Some(\"text/html\")")
  inspect(response.body.to_string(), content="Hello, World!")
}

///| Test parsing 404 Not Found response
async test "parse_response parses 404 Not Found response" {
  let response_str = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"
  let buffer = @buffer.HeapByteBuf::new(1024)
  write_utf8_string_serializer(buffer as &@buffer.Buffer, response_str)
  let response = try {
    parse_response(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::not_found())
    }
  }
  inspect(response.status.code, content="404")
  inspect(response.status.reason, content="Not Found")
  inspect(response.body.length(), content="0")
}

///| Test serializing a simple GET request
async test "serialize_request serializes GET request" {
  let request = HttpRequest::new(HttpMethod::GET, "/test", HttpVersion::HTTP_1_1)
  request.headers.add("Host", "example.com")
  request.headers.add("User-Agent", "TestClient/1.0")
  let buffer = @buffer.HeapByteBuf::new(1024)
  serialize_request(request, buffer as &@buffer.Buffer)
  let result = buffer.to_bytes().to_string()
  inspect(
    result.contains("GET /test HTTP/1.1"),
    content="true",
  )
  inspect(result.contains("Host: example.com"), content="true")
  inspect(
    result.contains("User-Agent: TestClient/1.0"),
    content="true",
  )
}

///| Test serializing POST request with body
async test "serialize_request serializes POST request with body" {
  let request = HttpRequest::new(
    HttpMethod::POST,
    "/api/data",
    HttpVersion::HTTP_1_1,
  )
  request.headers.add("Host", "api.example.com")
  request.headers.add("Content-Type", "application/json")
  let body = "{\"name\":\"test\"}"
  request.headers.add("Content-Length", body.length().to_string())
  request.set_body(body.to_bytes())
  let buffer = @buffer.HeapByteBuf::new(1024)
  serialize_request(request, buffer as &@buffer.Buffer)
  let result = buffer.to_bytes().to_string()
  inspect(
    result.contains("POST /api/data HTTP/1.1"),
    content="true",
  )
  inspect(
    result.contains("Content-Type: application/json"),
    content="true",
  )
  inspect(result.contains("{\"name\":\"test\"}"), content="true")
}

///| Test serializing HTTP response
async test "serialize_response serializes 200 OK response" {
  let response = HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
  response.headers.add("Content-Type", "text/plain")
  let body = "Success"
  response.headers.add("Content-Length", body.length().to_string())
  response.set_body(body.to_bytes())
  let buffer = @buffer.HeapByteBuf::new(1024)
  serialize_response(response, buffer as &@buffer.Buffer)
  let result = buffer.to_bytes().to_string()
  inspect(result.contains("HTTP/1.1 200 OK"), content="true")
  inspect(
    result.contains("Content-Type: text/plain"),
    content="true",
  )
  inspect(result.contains("Success"), content="true")
}

///| Test round-trip: serialize then parse request
async test "request round-trip serialize and parse" {
  let original = HttpRequest::new(
    HttpMethod::POST,
    "/submit",
    HttpVersion::HTTP_1_1,
  )
  original.headers.add("Host", "test.com")
  original.headers.add("Content-Type", "text/plain")
  let body = "test data"
  original.headers.add("Content-Length", body.length().to_string())
  original.set_body(body.to_bytes())
  
  // Serialize
  let buffer = @buffer.HeapByteBuf::new(1024)
  serialize_request(original, buffer as &@buffer.Buffer)
  
  // Parse back
  let parsed = try {
    parse_request(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::GET, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(parsed.method(), content="POST")
  inspect(parsed.uri, content="/submit")
  inspect(parsed.body.to_string(), content="test data")
}

///| Test round-trip: serialize then parse response
async test "response round-trip serialize and parse" {
  let original = HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
  original.headers.add("Content-Type", "application/json")
  let body = "{\"status\":\"ok\"}"
  original.headers.add("Content-Length", body.length().to_string())
  original.set_body(body.to_bytes())
  
  // Serialize
  let buffer = @buffer.HeapByteBuf::new(1024)
  serialize_response(original, buffer as &@buffer.Buffer)
  
  // Parse back
  let parsed = try {
    parse_response(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
    }
  }
  inspect(parsed.status.code, content="200")
  inspect(parsed.body.to_string(), content="{\"status\":\"ok\"}")
}

///| Helper to check if string contains substring
fn String::contains(self : String, needle : String) -> Bool {
  let len = self.length()
  let needle_len = needle.length()
  if needle_len > len {
    return false
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
      return true
    }
  }
  false
}
