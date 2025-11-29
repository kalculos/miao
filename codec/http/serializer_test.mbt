///| Tests for HTTP serializer

///|
/// Test writing simple GET request
async test "write simple GET request" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let request = HttpRequest::new(
    HttpMethod::GET,
    "/index.html",
    HttpVersion::HTTP_1_1,
  )
  request.headers.add("Host", "example.com")
  request.headers.add("User-Agent", "TestClient/1.0")
  let body = @buffer.HeapByteBuf::new(0)
  http_writer.write_request(request, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("GET /index.html HTTP/1.1"), content="true")
  inspect(result.contains("Host: example.com"), content="true")
  inspect(result.contains("User-Agent: TestClient/1.0"), content="true")
}

///|
/// Test writing POST request with body
async test "write POST request with body" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let request = HttpRequest::new(
    HttpMethod::POST,
    "/api/data",
    HttpVersion::HTTP_1_1,
  )
  request.headers.add("Host", "api.example.com")
  request.headers.add("Content-Type", "application/x-www-form-urlencoded")
  request.headers.add("Content-Length", "20")
  let body_content = "name=value&data=test"
  let body = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(body_content)
  body.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  http_writer.write_request(request, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("POST /api/data HTTP/1.1"), content="true")
  inspect(
    result.contains("Content-Type: application/x-www-form-urlencoded"),
    content="true",
  )
  inspect(result.contains("name=value&data=test"), content="true")
}

///|
/// Test writing 200 OK response
async test "write 200 OK response" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let response = HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
  response.headers.add("Content-Type", "text/html")
  response.headers.add("Content-Length", "13")
  let body_content = "Hello, World!"
  let body = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(body_content)
  body.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  http_writer.write_response(response, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("HTTP/1.1 200 OK"), content="true")
  inspect(result.contains("Content-Type: text/html"), content="true")
  inspect(result.contains("Hello, World!"), content="true")
}

///|
/// Test writing 404 Not Found response
async test "write 404 response" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let response = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::not_found(),
  )
  response.headers.add("Content-Type", "text/plain")
  response.headers.add("Content-Length", "9")
  let body_content = "Not Found"
  let body = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(body_content)
  body.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  http_writer.write_response(response, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("HTTP/1.1 404 Not Found"), content="true")
  inspect(result.contains("Not Found"), content="true")
}

///|
/// Test writing response with multiple headers
async test "write response with multiple headers" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let response = HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
  response.headers.add("Server", "MoonbitServer/1.0")
  response.headers.add("Content-Type", "application/json")
  response.headers.add("Cache-Control", "no-cache")
  response.headers.add("Content-Length", "0")
  let body = @buffer.HeapByteBuf::new(0)
  http_writer.write_response(response, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("Server: MoonbitServer/1.0"), content="true")
  inspect(result.contains("Content-Type: application/json"), content="true")
  inspect(result.contains("Cache-Control: no-cache"), content="true")
}

///|
/// Test writing PUT request
async test "write PUT request" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let request = HttpRequest::new(
    HttpMethod::PUT,
    "/resource/123",
    HttpVersion::HTTP_1_1,
  )
  request.headers.add("Host", "api.example.com")
  request.headers.add("Content-Length", "0")
  let body = @buffer.HeapByteBuf::new(0)
  http_writer.write_request(request, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("PUT /resource/123 HTTP/1.1"), content="true")
}

///|
/// Test writing DELETE request
async test "write DELETE request" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let request = HttpRequest::new(
    HttpMethod::DELETE,
    "/resource/456",
    HttpVersion::HTTP_1_1,
  )
  request.headers.add("Host", "api.example.com")
  let body = @buffer.HeapByteBuf::new(0)
  http_writer.write_request(request, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("DELETE /resource/456 HTTP/1.1"), content="true")
}

///|
/// Test writing request with JSON body
async test "write request with JSON body" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let request = HttpRequest::new(
    HttpMethod::POST,
    "/api/json",
    HttpVersion::HTTP_1_1,
  )
  request.headers.add("Content-Type", "application/json")
  let json_body = "{\"name\":\"test\",\"value\":42}"
  request.headers.add("Content-Length", json_body.length().to_string())
  let body = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(json_body)
  body.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  http_writer.write_request(request, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("Content-Type: application/json"), content="true")
  inspect(result.contains("{\"name\":\"test\",\"value\":42}"), content="true")
}

///|
/// Test writing 500 Internal Server Error response
async test "write 500 error response" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let response = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::internal_server_error(),
  )
  response.headers.add("Content-Length", "0")
  let body = @buffer.HeapByteBuf::new(0)
  http_writer.write_response(response, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("HTTP/1.1 500 Internal Server Error"), content="true")
}

///|
/// Test writing HTTP/1.0 request
async test "write HTTP/1.0 request" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let request = HttpRequest::new(HttpMethod::GET, "/", HttpVersion::HTTP_1_0)
  request.headers.add("Host", "oldserver.com")
  let body = @buffer.HeapByteBuf::new(0)
  http_writer.write_request(request, body as &@buffer.Buffer)
  let result = @encoding/utf8.decode(buffer.to_bytes())
  inspect(result.contains("GET / HTTP/1.0"), content="true")
  inspect(result.contains("Host: oldserver.com"), content="true")
}

///|
/// Test writing all HTTP methods
async test "write all HTTP methods" {
  let methods = [
    HttpMethod::GET,
    HttpMethod::POST,
    HttpMethod::PUT,
    HttpMethod::DELETE,
    HttpMethod::HEAD,
    HttpMethod::OPTIONS,
    HttpMethod::PATCH,
    HttpMethod::CONNECT,
    HttpMethod::TRACE,
  ]
  for i = 0; i < methods.length(); i = i + 1 {
    let http_method = methods[i]
    let buffer = @buffer.HeapByteBuf::new(1024)
    let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
    let http_writer = HttpWriter::new(writer as &@io.Writer)
    let request = HttpRequest::new(http_method, "/test", HttpVersion::HTTP_1_1)
    let body = @buffer.HeapByteBuf::new(0)
    http_writer.write_request(request, body as &@buffer.Buffer)
    let result = @encoding/utf8.decode(buffer.to_bytes())
    inspect(result.contains(http_method.to_string()), content="true")
  }
}

///|
/// Test round-trip: write then read request
async test "round-trip write and read request" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let original_request = HttpRequest::new(
    HttpMethod::POST,
    "/api/test",
    HttpVersion::HTTP_1_1,
  )
  original_request.headers.add("Host", "test.com")
  original_request.headers.add("Content-Type", "text/plain")
  let body_text = "test body"
  original_request.headers.add("Content-Length", body_text.length().to_string())
  let body = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(body_text)
  body.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  http_writer.write_request(original_request, body as &@buffer.Buffer)

  // Now read it back
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  let parsed_request = http_reader.read_request()
  inspect(parsed_request.method() == HttpMethod::POST, content="true")
  inspect(parsed_request.uri, content="/api/test")
  inspect(parsed_request.version == HttpVersion::HTTP_1_1, content="true")
  inspect(parsed_request.headers.get("Host"), content="Some(\"test.com\")")
  inspect(
    parsed_request.headers.get("Content-Type"),
    content="Some(\"text/plain\")",
  )
}

///|
/// Test round-trip: write then read response
async test "round-trip write and read response" {
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  let original_response = HttpResponse::new(
    HttpVersion::HTTP_1_1,
    HttpStatus::ok(),
  )
  original_response.headers.add("Content-Type", "application/json")
  let body_text = "{\"ok\":true}"
  original_response.headers.add(
    "Content-Length",
    body_text.length().to_string(),
  )
  let body = @buffer.HeapByteBuf::new(100)
  let body_bytes = @encoding/utf8.encode(body_text)
  body.write(body_bytes.to_fixedarray(), 0, body_bytes.length()) |> ignore
  http_writer.write_response(original_response, body as &@buffer.Buffer)

  // Now read it back
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  let parsed_response = http_reader.read_response()
  inspect(parsed_response.version == HttpVersion::HTTP_1_1, content="true")
  inspect(parsed_response.status.code, content="200")
  inspect(parsed_response.status.reason, content="OK")
  inspect(
    parsed_response.headers.get("Content-Type"),
    content="Some(\"application/json\")",
  )
  match parsed_response.content_reader {
    Some(content_reader) => {
      let body  = content_reader.read_all().to_bytes()
      inspect(@encoding/utf8.decode(body[:]), content="{\"ok\":true}")
    }
    None => inspect(false, content="Should have content reader")
  }
}
