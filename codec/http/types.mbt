///|
/// HTTP/1.1 Methods
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

///|
/// Convert HttpMethod to String
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

///|
/// Parse HttpMethod from String
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

///|
/// HTTP Version
pub(all) enum HttpVersion {
  HTTP_1_0
  HTTP_1_1
} derive(Eq, Show)

///|
/// Convert HttpVersion to String
pub fn HttpVersion::to_string(self : HttpVersion) -> String {
  match self {
    HTTP_1_0 => "HTTP/1.0"
    HTTP_1_1 => "HTTP/1.1"
  }
}

///|
/// Parse HttpVersion from String
pub fn HttpVersion::from_string(s : String) -> HttpVersion raise {
  match s {
    "HTTP/1.0" => HTTP_1_0
    "HTTP/1.1" => HTTP_1_1
    _ => raise fail("Invalid HTTP version: " + s)
  }
}

///|
/// HTTP Status Code
pub struct HttpStatus {
  code : Int
  reason : String
} derive(Eq, Show)

///|
/// Common HTTP Status Codes - 1xx Informational
pub fn HttpStatus::continue_() -> HttpStatus {
  { code: 100, reason: "Continue" }
}

///|
pub fn HttpStatus::switching_protocols() -> HttpStatus {
  { code: 101, reason: "Switching Protocols" }
}

///|
/// Common HTTP Status Codes - 2xx Success
pub fn HttpStatus::ok() -> HttpStatus {
  { code: 200, reason: "OK" }
}

///|
pub fn HttpStatus::created() -> HttpStatus {
  { code: 201, reason: "Created" }
}

///|
pub fn HttpStatus::accepted() -> HttpStatus {
  { code: 202, reason: "Accepted" }
}

///|
pub fn HttpStatus::no_content() -> HttpStatus {
  { code: 204, reason: "No Content" }
}

///|
/// Common HTTP Status Codes - 3xx Redirection
pub fn HttpStatus::moved_permanently() -> HttpStatus {
  { code: 301, reason: "Moved Permanently" }
}

///|
pub fn HttpStatus::found() -> HttpStatus {
  { code: 302, reason: "Found" }
}

///|
pub fn HttpStatus::see_other() -> HttpStatus {
  { code: 303, reason: "See Other" }
}

///|
pub fn HttpStatus::not_modified() -> HttpStatus {
  { code: 304, reason: "Not Modified" }
}

///|
pub fn HttpStatus::temporary_redirect() -> HttpStatus {
  { code: 307, reason: "Temporary Redirect" }
}

///|
pub fn HttpStatus::permanent_redirect() -> HttpStatus {
  { code: 308, reason: "Permanent Redirect" }
}

///|
/// Common HTTP Status Codes - 4xx Client Error
pub fn HttpStatus::bad_request() -> HttpStatus {
  { code: 400, reason: "Bad Request" }
}

///|
pub fn HttpStatus::unauthorized() -> HttpStatus {
  { code: 401, reason: "Unauthorized" }
}

///|
pub fn HttpStatus::payment_required() -> HttpStatus {
  { code: 402, reason: "Payment Required" }
}

///|
pub fn HttpStatus::forbidden() -> HttpStatus {
  { code: 403, reason: "Forbidden" }
}

///|
pub fn HttpStatus::not_found() -> HttpStatus {
  { code: 404, reason: "Not Found" }
}

///|
pub fn HttpStatus::method_not_allowed() -> HttpStatus {
  { code: 405, reason: "Method Not Allowed" }
}

///|
pub fn HttpStatus::conflict() -> HttpStatus {
  { code: 409, reason: "Conflict" }
}

///|
pub fn HttpStatus::gone() -> HttpStatus {
  { code: 410, reason: "Gone" }
}

///|
pub fn HttpStatus::unprocessable_entity() -> HttpStatus {
  { code: 422, reason: "Unprocessable Entity" }
}

///|
pub fn HttpStatus::too_many_requests() -> HttpStatus {
  { code: 429, reason: "Too Many Requests" }
}

///|
/// Common HTTP Status Codes - 5xx Server Error
pub fn HttpStatus::internal_server_error() -> HttpStatus {
  { code: 500, reason: "Internal Server Error" }
}

///|
pub fn HttpStatus::not_implemented() -> HttpStatus {
  { code: 501, reason: "Not Implemented" }
}

///|
pub fn HttpStatus::bad_gateway() -> HttpStatus {
  { code: 502, reason: "Bad Gateway" }
}

///|
pub fn HttpStatus::service_unavailable() -> HttpStatus {
  { code: 503, reason: "Service Unavailable" }
}

///|
pub fn HttpStatus::gateway_timeout() -> HttpStatus {
  { code: 504, reason: "Gateway Timeout" }
}

///|
pub fn HttpStatus::new(code : Int, reason : String) -> HttpStatus {
  { code, reason }
}

///|
/// Check if status is informational (1xx)
pub fn HttpStatus::is_informational(self : HttpStatus) -> Bool {
  self.code >= 100 && self.code < 200
}

///|
/// Check if status is success (2xx)
pub fn HttpStatus::is_success(self : HttpStatus) -> Bool {
  self.code >= 200 && self.code < 300
}

///|
/// Check if status is redirection (3xx)
pub fn HttpStatus::is_redirection(self : HttpStatus) -> Bool {
  self.code >= 300 && self.code < 400
}

///|
/// Check if status is client error (4xx)
pub fn HttpStatus::is_client_error(self : HttpStatus) -> Bool {
  self.code >= 400 && self.code < 500
}

///|
/// Check if status is server error (5xx)
pub fn HttpStatus::is_server_error(self : HttpStatus) -> Bool {
  self.code >= 500 && self.code < 600
}

///|
/// Check if status is any error (4xx or 5xx)
pub fn HttpStatus::is_error(self : HttpStatus) -> Bool {
  self.code >= 400
}

///|
/// HTTP Headers
pub struct HttpHeaders {
  headers : Array[(String, String)]
}

///|
/// Create new HttpHeaders
pub fn HttpHeaders::new() -> HttpHeaders {
  { headers: Array::new() }
}

///|
/// Add a header
pub fn HttpHeaders::add(
  self : HttpHeaders,
  name : String,
  value : String,
) -> Unit {
  self.headers.push((name, value))
}

///|
/// Get a header value by name (case-insensitive)
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

///|
/// Get all header values by name (case-insensitive)
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

///|
/// Remove all headers with the given name (case-insensitive)
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

///|
/// Get the number of headers
pub fn HttpHeaders::length(self : HttpHeaders) -> Int {
  self.headers.length()
}

///|
/// Set a header (replaces existing values with same name)
pub fn HttpHeaders::set(
  self : HttpHeaders,
  name : String,
  value : String,
) -> Unit {
  self.remove(name)
  self.add(name, value)
}

///|
/// Check if a header exists (case-insensitive)
pub fn HttpHeaders::contains(self : HttpHeaders, name : String) -> Bool {
  not(self.get(name).is_empty())
}

///|
/// HTTP Content Reader for lazy body reading
pub struct HttpContentReader {
  reader : &@io.Reader
  content_length : Int
  mut bytes_read : Int
}

///|
/// Create a new HttpContentReader
pub fn HttpContentReader::new(
  reader : &@io.Reader,
  content_length : Int,
) -> HttpContentReader {
  { reader, content_length, bytes_read: 0 }
}

///|
/// Read all remaining content
pub async fn HttpContentReader::read_all(
  self : HttpContentReader,
) -> &@buffer.Buffer {
  let remaining = self.content_length - self.bytes_read
  if remaining <= 0 {
    return @buffer.HeapByteBuf::new(0)
  }
  let buffer = self.reader.read_buffer(remaining)
  self.bytes_read = self.bytes_read + buffer.readable_bytes()
  buffer
}

///|
/// Read up to n bytes from the content
pub async fn HttpContentReader::read(
  self : HttpContentReader,
  n : Int,
) -> &@buffer.Buffer {
  let remaining = self.content_length - self.bytes_read
  let to_read = if n < remaining { n } else { remaining }
  if to_read <= 0 {
    return @buffer.HeapByteBuf::new(0)
  }
  let buffer = self.reader.read_buffer(to_read)
  self.bytes_read = self.bytes_read + buffer.readable_bytes()
  buffer
}

///|
/// Get the total content length
pub fn HttpContentReader::content_length(self : HttpContentReader) -> Int {
  self.content_length
}

///|
/// Get the number of bytes already read
pub fn HttpContentReader::bytes_read(self : HttpContentReader) -> Int {
  self.bytes_read
}

///|
/// Check if there's more content to read
pub fn HttpContentReader::has_more(self : HttpContentReader) -> Bool {
  self.bytes_read < self.content_length
}

///|
/// HTTP Request
pub struct HttpRequest {
  http_method : HttpMethod
  uri : String
  version : HttpVersion
  headers : HttpHeaders
  content_reader : HttpContentReader?
}

///|
/// Create new HttpRequest
pub fn HttpRequest::new(
  http_method : HttpMethod,
  uri : String,
  version : HttpVersion,
) -> HttpRequest {
  {
    http_method,
    uri,
    version,
    headers: HttpHeaders::new(),
    content_reader: None,
  }
}

///|
/// Get method from request
pub fn HttpRequest::method(self : HttpRequest) -> HttpMethod {
  self.http_method
}

///|
/// Get URI from request
pub fn HttpRequest::uri(self : HttpRequest) -> String {
  self.uri
}

///|
/// Get version from request
pub fn HttpRequest::version(self : HttpRequest) -> HttpVersion {
  self.version
}

///|
/// Get the content reader if available
pub fn HttpRequest::content_reader(self : HttpRequest) -> HttpContentReader? {
  self.content_reader
}

///|
/// HTTP Response
pub struct HttpResponse {
  version : HttpVersion
  status : HttpStatus
  headers : HttpHeaders
  content_reader : HttpContentReader?
}

///|
/// Create new HttpResponse
pub fn HttpResponse::new(
  version : HttpVersion,
  status : HttpStatus,
) -> HttpResponse {
  { version, status, headers: HttpHeaders::new(), content_reader: None }
}

///|
/// Get version from response
pub fn HttpResponse::version(self : HttpResponse) -> HttpVersion {
  self.version
}

///|
/// Get status from response
pub fn HttpResponse::status(self : HttpResponse) -> HttpStatus {
  self.status
}

///|
/// Get the content reader if available
pub fn HttpResponse::content_reader(self : HttpResponse) -> HttpContentReader? {
  self.content_reader
}
