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

///| HTTP Content Reader for lazy body reading
pub struct HttpContentReader {
  reader : &@io.Reader
  content_length : Int
  mut bytes_read : Int
}

///| Create a new HttpContentReader
pub fn HttpContentReader::new(reader : &@io.Reader, content_length : Int) -> HttpContentReader {
  { reader, content_length, bytes_read: 0 }
}

///| Read all remaining content
pub async fn HttpContentReader::read_all(self : HttpContentReader) -> Bytes raise {
  let remaining = self.content_length - self.bytes_read
  if remaining <= 0 {
    return b""
  }
  
  let arr : FixedArray[Byte] = FixedArray::make(remaining, 0)
  let mut total_read = 0
  
  while total_read < remaining {
    let read = self.reader.read(arr, total_read, remaining - total_read)
    if read == 0 {
      raise fail("Unexpected EOF: expected " + remaining.to_string() + " bytes, got " + total_read.to_string())
    }
    total_read = total_read + read
  }
  
  self.bytes_read = self.bytes_read + total_read
  Bytes::from_array(arr)
}

///| Read up to n bytes from the content
pub async fn HttpContentReader::read(self : HttpContentReader, n : Int) -> Bytes raise {
  let remaining = self.content_length - self.bytes_read
  let to_read = if n < remaining { n } else { remaining }
  
  if to_read <= 0 {
    return b""
  }
  
  let arr : FixedArray[Byte] = FixedArray::make(to_read, 0)
  let mut total_read = 0
  
  while total_read < to_read {
    let read = self.reader.read(arr, total_read, to_read - total_read)
    if read == 0 {
      break
    }
    total_read = total_read + read
  }
  
  self.bytes_read = self.bytes_read + total_read
  Bytes::from_array(arr)
}

///| Get the total content length
pub fn HttpContentReader::content_length(self : HttpContentReader) -> Int {
  self.content_length
}

///| Get the number of bytes already read
pub fn HttpContentReader::bytes_read(self : HttpContentReader) -> Int {
  self.bytes_read
}

///| Check if there's more content to read
pub fn HttpContentReader::has_more(self : HttpContentReader) -> Bool {
  self.bytes_read < self.content_length
}

///| HTTP Request
pub struct HttpRequest {
  http_method : HttpMethod
  uri : String
  version : HttpVersion
  headers : HttpHeaders
  content_reader : HttpContentReader?
}

///| Create new HttpRequest
pub fn HttpRequest::new(
  http_method : HttpMethod,
  uri : String,
  version : HttpVersion
) -> HttpRequest {
  { http_method, uri, version, headers: HttpHeaders::new(), content_reader: None }
}

///| Get method from request
pub fn HttpRequest::method(self : HttpRequest) -> HttpMethod {
  self.http_method
}

///| Get the content reader if available
pub fn HttpRequest::content_reader(self : HttpRequest) -> HttpContentReader? {
  self.content_reader
}

///| HTTP Response
pub struct HttpResponse {
  version : HttpVersion
  status : HttpStatus
  headers : HttpHeaders
  content_reader : HttpContentReader?
}

///| Create new HttpResponse
pub fn HttpResponse::new(version : HttpVersion, status : HttpStatus) -> HttpResponse {
  { version, status, headers: HttpHeaders::new(), content_reader: None }
}