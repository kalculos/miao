///| Tests for HTTP response parser and serializer

///| Test parsing a simple 200 OK response
async test "parse_response parses 200 OK response" {
  let response_str = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: 13\r\n\r\nHello, World!"
  let buffer = @buffer.HeapByteBuf::new(1024)
  let bytes = @encoding/utf8.encode(response_str)
  buffer.write(bytes.to_fixedarray(), 0, bytes.length()) |> ignore
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  let response = try {
    http_reader.read_response()
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
  
  // Read body
  match response.content_reader {
    Some(content_reader) => {
      let body = try {
        content_reader.read_all()
      } catch {
        e => {
          inspect(e, content="Should not fail reading body")
          b""
        }
      }
      inspect(@encoding/utf8.decode(body), content="Hello, World!")
    }
    None => inspect(false, content="Should have content reader")
  }
}

///| Test parsing 404 Not Found response
async test "parse_response parses 404 Not Found response" {
  let response_str = "HTTP/1.1 404 Not Found\r\nContent-Length: 0\r\n\r\n"
  let buffer = @buffer.HeapByteBuf::new(1024)
  let bytes = @encoding/utf8.encode(response_str)
  buffer.write(bytes.to_fixedarray(), 0, bytes.length()) |> ignore
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  let response = try {
    http_reader.read_response()
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::not_found())
    }
  }
  inspect(response.status.code, content="404")
  inspect(response.status.reason, content="Not Found")
  inspect(response.content_reader.is_empty(), content="true")
}

///| Test serializing a simple GET request
async test "serialize_request serializes GET request" {
  let request = HttpRequest::new(HttpMethod::GET, "/test", HttpVersion::HTTP_1_1)
  request.headers.add("Host", "example.com")
  request.headers.add("User-Agent", "TestClient/1.0")
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  http_writer.write_request(request, None)
  let result = @encoding/utf8.decode(buffer.to_bytes())
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
  let body_str = "{\"name\":\"test\"}"
  let body = @encoding/utf8.encode(body_str)
  request.headers.add("Content-Length", body.length().to_string())
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  http_writer.write_request(request, Some(body))
  let result = @encoding/utf8.decode(buffer.to_bytes())
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
  let body_str = "Success"
  let body = @encoding/utf8.encode(body_str)
  response.headers.add("Content-Length", body.length().to_string())
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  http_writer.write_response(response, Some(body))
  let result = @encoding/utf8.decode(buffer.to_bytes())
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
  let body_str = "test data"
  let body = @encoding/utf8.encode(body_str)
  original.headers.add("Content-Length", body.length().to_string())
  
  // Serialize
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  http_writer.write_request(original, Some(body))
  
  // Parse back
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  let parsed = try {
    http_reader.read_request()
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::GET, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(parsed.method(), content="POST")
  inspect(parsed.uri, content="/submit")
  
  // Read body
  match parsed.content_reader() {
    Some(content_reader) => {
      let read_body = try {
        content_reader.read_all()
      } catch {
        e => {
          inspect(e, content="Should not fail reading body")
          b""
        }
      }
      inspect(@encoding/utf8.decode(read_body), content="test data")
    }
    None => inspect(false, content="Should have content reader")
  }
}

///| Test round-trip: serialize then parse response
async test "response round-trip serialize and parse" {
  let original = HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
  original.headers.add("Content-Type", "application/json")
  let body_str = "{\"status\":\"ok\"}"
  let body = @encoding/utf8.encode(body_str)
  original.headers.add("Content-Length", body.length().to_string())
  
  // Serialize
  let buffer = @buffer.HeapByteBuf::new(1024)
  let writer = @io.ByteBufWriter::new(buffer as &@buffer.Buffer)
  let http_writer = HttpWriter::new(writer as &@io.Writer)
  http_writer.write_response(original, Some(body))
  
  // Parse back
  let reader = @io.ByteBufReader::new(buffer as &@buffer.Buffer)
  let http_reader = HttpReader::new(reader as &@io.Reader)
  let parsed = try {
    http_reader.read_response()
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
    }
  }
  inspect(parsed.status.code, content="200")
  
  // Read body
  match parsed.content_reader {
    Some(content_reader) => {
      let read_body = try {
        content_reader.read_all()
      } catch {
        e => {
          inspect(e, content="Should not fail reading body")
          b""
        }
      }
      inspect(@encoding/utf8.decode(read_body), content="{\"status\":\"ok\"}")
    }
    None => inspect(false, content="Should have content reader")
  }
}
