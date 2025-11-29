///|
/// Tests for HTTP codec types
test "HttpMethod::to_string converts correctly" {
  inspect(HttpMethod::GET.to_string(), content="GET")
  inspect(HttpMethod::POST.to_string(), content="POST")
  inspect(HttpMethod::PUT.to_string(), content="PUT")
  inspect(HttpMethod::DELETE.to_string(), content="DELETE")
}

///|
test "HttpMethod::from_string parses correctly" {
  inspect(
    HttpMethod::from_string("GET") catch {
      _ => HttpMethod::TRACE
    },
    content="GET",
  )
  inspect(
    HttpMethod::from_string("POST") catch {
      _ => HttpMethod::TRACE
    },
    content="POST",
  )
}

///|
test "HttpVersion::to_string converts correctly" {
  inspect(HttpVersion::HTTP_1_0.to_string(), content="HTTP/1.0")
  inspect(HttpVersion::HTTP_1_1.to_string(), content="HTTP/1.1")
}

///|
test "HttpVersion::from_string parses correctly" {
  inspect(
    HttpVersion::from_string("HTTP/1.1") catch {
      _ => HttpVersion::HTTP_1_0
    },
    content="HTTP_1_1",
  )
}

///|
test "HttpStatus common status codes" {
  let ok = HttpStatus::ok()
  inspect(ok.code, content="200")
  inspect(ok.reason, content="OK")
  let not_found = HttpStatus::not_found()
  inspect(not_found.code, content="404")
  inspect(not_found.reason, content="Not Found")
}

///|
test "HttpHeaders add and get" {
  let headers = HttpHeaders::new()
  headers.add("Content-Type", "text/html")
  headers.add("Content-Length", "100")
  inspect(headers.get("Content-Type"), content="Some(\"text/html\")")
  inspect(headers.get("content-type"), content="Some(\"text/html\")")
  inspect(headers.get("Missing"), content="None")
}

///|
test "HttpHeaders get_all returns all matching headers" {
  let headers = HttpHeaders::new()
  headers.add("Set-Cookie", "a=1")
  headers.add("Set-Cookie", "b=2")
  headers.add("Content-Type", "text/html")
  let cookies = headers.get_all("Set-Cookie")
  inspect(cookies.length(), content="2")
  inspect(cookies[0], content="a=1")
  inspect(cookies[1], content="b=2")
}

///|
test "HttpHeaders remove removes all matching headers" {
  let headers = HttpHeaders::new()
  headers.add("X-Custom", "value1")
  headers.add("X-Custom", "value2")
  headers.add("Content-Type", "text/html")
  inspect(headers.length(), content="3")
  headers.remove("X-Custom")
  inspect(headers.length(), content="1")
  inspect(headers.get("X-Custom"), content="None")
}

///|
test "HttpRequest::new creates request with empty headers" {
  let request = HttpRequest::new(HttpMethod::GET, "/", HttpVersion::HTTP_1_1)
  inspect(request.method(), content="GET")
  inspect(request.uri, content="/")
  inspect(request.version, content="HTTP_1_1")
  inspect(request.headers.length(), content="0")
}

///|
test "HttpResponse::new creates response with empty headers" {
  let response = HttpResponse::new(HttpVersion::HTTP_1_1, HttpStatus::ok())
  inspect(response.version, content="HTTP_1_1")
  inspect(response.status.code, content="200")
  inspect(response.headers.length(), content="0")
}
