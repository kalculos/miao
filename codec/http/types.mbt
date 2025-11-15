///| HTTP/1.1 Methods
pub(all) enum HttpMethod {
  GET
  POST
  PUT
  DELETE
  HEAD
  OPTIONS
  PATCH
  CONNECT
  TRACE
} derive(Eq, Show)

///| Convert HttpMethod to String
pub fn HttpMethod::to_string(self : HttpMethod) -> String {
  match self {
    GET => "GET"
    POST => "POST"
    PUT => "PUT"
    DELETE => "DELETE"
    HEAD => "HEAD"
    OPTIONS => "OPTIONS"
    PATCH => "PATCH"
    CONNECT => "CONNECT"
    TRACE => "TRACE"
  }
}

///| Parse HttpMethod from String
pub fn HttpMethod::from_string(s : String) -> HttpMethod raise {
  match s {
    "GET" => GET
    "POST" => POST
    "PUT" => PUT
    "DELETE" => DELETE
    "HEAD" => HEAD
    "OPTIONS" => OPTIONS
    "PATCH" => PATCH
    "CONNECT" => CONNECT
    "TRACE" => TRACE
    _ => raise fail("Invalid HTTP method: " + s)
  }
}

///| HTTP Version
pub(all) enum HttpVersion {
  HTTP_1_0
  HTTP_1_1
} derive(Eq, Show)

///| Convert HttpVersion to String
pub fn HttpVersion::to_string(self : HttpVersion) -> String {
  match self {
    HTTP_1_0 => "HTTP/1.0"
    HTTP_1_1 => "HTTP/1.1"
  }
}

///| Parse HttpVersion from String
pub fn HttpVersion::from_string(s : String) -> HttpVersion raise {
  match s {
    "HTTP/1.0" => HTTP_1_0
    "HTTP/1.1" => HTTP_1_1
    _ => raise fail("Invalid HTTP version: " + s)
  }
}

///| HTTP Status Code
pub struct HttpStatus {
  code : Int
  reason : String
} derive(Eq, Show)

///| Common HTTP Status Codes
pub fn HttpStatus::ok() -> HttpStatus {
  { code: 200, reason: "OK" }
}

pub fn HttpStatus::created() -> HttpStatus {
  { code: 201, reason: "Created" }
}

pub fn HttpStatus::no_content() -> HttpStatus {
  { code: 204, reason: "No Content" }
}

pub fn HttpStatus::bad_request() -> HttpStatus {
  { code: 400, reason: "Bad Request" }
}

pub fn HttpStatus::unauthorized() -> HttpStatus {
  { code: 401, reason: "Unauthorized" }
}

pub fn HttpStatus::forbidden() -> HttpStatus {
  { code: 403, reason: "Forbidden" }
}

pub fn HttpStatus::not_found() -> HttpStatus {
  { code: 404, reason: "Not Found" }
}

pub fn HttpStatus::internal_server_error() -> HttpStatus {
  { code: 500, reason: "Internal Server Error" }
}

pub fn HttpStatus::new(code : Int, reason : String) -> HttpStatus {
  { code, reason }
}

///| HTTP Headers
pub struct HttpHeaders {
  headers : Array[(String, String)]
}

///| Create new HttpHeaders
pub fn HttpHeaders::new() -> HttpHeaders {
  { headers: Array::new() }
}

///| Add a header
pub fn HttpHeaders::add(self : HttpHeaders, name : String, value : String) -> Unit {
  self.headers.push((name, value))
}

///| Get a header value by name (case-insensitive)
pub fn HttpHeaders::get(self : HttpHeaders, name : String) -> String? {
  let lower_name = name.to_lower()
  for i = 0; i < self.headers.length(); i = i + 1 {
    let (h_name, h_value) = self.headers[i]
    if h_name.to_lower() == lower_name {
      return Some(h_value)
    }
  }
  None
}

///| Get all header values by name (case-insensitive)
pub fn HttpHeaders::get_all(self : HttpHeaders, name : String) -> Array[String] {
  let lower_name = name.to_lower()
  let result = Array::new()
  for i = 0; i < self.headers.length(); i = i + 1 {
    let (h_name, h_value) = self.headers[i]
    if h_name.to_lower() == lower_name {
      result.push(h_value)
    }
  }
  result
}

///| Remove all headers with the given name (case-insensitive)
pub fn HttpHeaders::remove(self : HttpHeaders, name : String) -> Unit {
  let lower_name = name.to_lower()
  let mut i = 0
  while i < self.headers.length() {
    let (h_name, _) = self.headers[i]
    if h_name.to_lower() == lower_name {
      self.headers.remove(i) |> ignore
    } else {
      i = i + 1
    }
  }
}

///| Get the number of headers
pub fn HttpHeaders::length(self : HttpHeaders) -> Int {
  self.headers.length()
}

///| HTTP Request
pub struct HttpRequest {
  http_method : HttpMethod
  uri : String
  version : HttpVersion
  headers : HttpHeaders
  mut body : Bytes
}

///| Create new HttpRequest
pub fn HttpRequest::new(
  http_method : HttpMethod,
  uri : String,
  version : HttpVersion
) -> HttpRequest {
  { http_method, uri, version, headers: HttpHeaders::new(), body: b"" }
}

///| Get method from request
pub fn HttpRequest::method(self : HttpRequest) -> HttpMethod {
  self.http_method
}

///| Set body for request
pub fn HttpRequest::set_body(self : HttpRequest, body : Bytes) -> Unit {
  self.body = body
}

///| HTTP Response
pub struct HttpResponse {
  version : HttpVersion
  status : HttpStatus
  headers : HttpHeaders
  mut body : Bytes
}

///| Create new HttpResponse
pub fn HttpResponse::new(version : HttpVersion, status : HttpStatus) -> HttpResponse {
  { version, status, headers: HttpHeaders::new(), body: b"" }
}

///| Set body for response
pub fn HttpResponse::set_body(self : HttpResponse, body : Bytes) -> Unit {
  self.body = body
}
