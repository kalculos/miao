///| Tests for HTTP request parser

///| Test parsing a simple GET request
async test "parse_request parses simple GET request" {
  let request_str = "GET /index.html HTTP/1.1\r\nHost: example.com\r\nUser-Agent: TestClient/1.0\r\n\r\n"
  let buffer = @buffer.HeapByteBuf::new(1024)
  buffer.write(request_str.to_bytes().to_fixedarray(), 0, request_str.length())
    |> ignore
  let request = try {
    parse_request(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::GET, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(request.method(), content="GET")
  inspect(request.uri, content="/index.html")
  inspect(request.version, content="HTTP/1.1")
  inspect(request.headers.get("Host"), content="Some(example.com)")
  inspect(request.headers.get("User-Agent"), content="Some(TestClient/1.0)")
  inspect(request.body.length(), content="0")
}

///| Test parsing a POST request with body
async test "parse_request parses POST request with body" {
  let body_content = "name=value&data=test"
  let request_str = "POST /api/data HTTP/1.1\r\nHost: api.example.com\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: " +
    body_content.length().to_string() + "\r\n\r\n" + body_content
  let buffer = @buffer.HeapByteBuf::new(1024)
  buffer.write(request_str.to_bytes().to_fixedarray(), 0, request_str.length())
    |> ignore
  let request = try {
    parse_request(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::POST, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(request.method(), content="POST")
  inspect(request.uri, content="/api/data")
  inspect(request.headers.get("Content-Type"), content="Some(application/x-www-form-urlencoded)")
  inspect(request.body.length(), content="20")
  inspect(request.body.to_string(), content="name=value&data=test")
}

///| Test parsing request with multiple headers
async test "parse_request handles multiple headers" {
  let request_str = "GET /test HTTP/1.1\r\nHost: example.com\r\nAccept: text/html\r\nAccept-Encoding: gzip, deflate\r\nConnection: keep-alive\r\n\r\n"
  let buffer = @buffer.HeapByteBuf::new(1024)
  buffer.write(request_str.to_bytes().to_fixedarray(), 0, request_str.length())
    |> ignore
  let request = try {
    parse_request(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::GET, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(request.headers.length() >= 4, content="true")
  inspect(request.headers.get("Accept"), content="Some(text/html)")
  inspect(
    request.headers.get("Accept-Encoding"),
    content="Some(gzip, deflate)",
  )
}

///| Test parsing request with URI containing query parameters
async test "parse_request handles query parameters in URI" {
  let request_str = "GET /search?q=moonbit&lang=en HTTP/1.1\r\nHost: search.example.com\r\n\r\n"
  let buffer = @buffer.HeapByteBuf::new(1024)
  buffer.write(request_str.to_bytes().to_fixedarray(), 0, request_str.length())
    |> ignore
  let request = try {
    parse_request(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::GET, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(request.uri, content="/search?q=moonbit&lang=en")
}

///| Test parsing PUT request
async test "parse_request parses PUT request" {
  let request_str = "PUT /resource/123 HTTP/1.1\r\nHost: api.example.com\r\nContent-Length: 0\r\n\r\n"
  let buffer = @buffer.HeapByteBuf::new(1024)
  buffer.write(request_str.to_bytes().to_fixedarray(), 0, request_str.length())
    |> ignore
  let request = try {
    parse_request(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::PUT, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(request.method(), content="PUT")
  inspect(request.uri, content="/resource/123")
}

///| Test parsing DELETE request
async test "parse_request parses DELETE request" {
  let request_str = "DELETE /resource/456 HTTP/1.1\r\nHost: api.example.com\r\n\r\n"
  let buffer = @buffer.HeapByteBuf::new(1024)
  buffer.write(request_str.to_bytes().to_fixedarray(), 0, request_str.length())
    |> ignore
  let request = try {
    parse_request(buffer as &@buffer.Buffer)
  } catch {
    e => {
      inspect(e, content="Should not fail")
      HttpRequest::new(HttpMethod::DELETE, "/", HttpVersion::HTTP_1_1)
    }
  }
  inspect(request.method(), content="DELETE")
  inspect(request.uri, content="/resource/456")
}
