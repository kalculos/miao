///| URI parsing and manipulation

///|
/// Represents a parsed URI with path and query parameters
pub struct Uri {
  raw : String
  path : String
  query : Map[String, Array[String]]
  fragment : String?
}

///|
/// Parse a URI string into components
pub fn Uri::parse(uri : String) -> Uri {
  // Find fragment first
  let (uri_without_fragment, fragment) = match uri.find("#") {
    Some(pos) => {
      let fragment = substring(uri, pos + 1, uri.length())
      let uri_part = substring(uri, 0, pos)
      (uri_part, Some(fragment))
    }
    None => (uri, None)
  }

  // Find query string
  let (path, query) = match uri_without_fragment.find("?") {
    Some(pos) => {
      let path = substring(uri_without_fragment, 0, pos)
      let query_str = substring(
        uri_without_fragment,
        pos + 1,
        uri_without_fragment.length(),
      )
      (path, parse_query_string(query_str))
    }
    None => (uri_without_fragment, Map::new())
  }
  { raw: uri, path, query, fragment }
}

///|
/// Parse query string into a map of key-value pairs
fn parse_query_string(query_str : String) -> Map[String, Array[String]] {
  let result : Map[String, Array[String]] = Map::new()
  if query_str.is_empty() {
    return result
  }
  let pairs = query_str.split("&")
  for pair in pairs {
    let pair_str = pair.to_string()
    match pair_str.find("=") {
      Some(pos) => {
        let key = url_decode(substring(pair_str, 0, pos))
        let value = url_decode(substring(pair_str, pos + 1, pair_str.length()))
        match result.get(key) {
          Some(existing) => existing.push(value)
          None => result.set(key, [value])
        }
      }
      None => {
        // Do not add key if there is no value (skip)
        // This ensures get_query("flag") returns None as expected
        ()
      }
    }
  }
  result
}

///|
/// URL decode a string (percent encoding)
pub fn url_decode(s : String) -> String {
  let result_bytes : Array[Byte] = []
  let mut i = 0
  let len = s.length()
  while i < len {
    let ch_code = s[i]
    let ch = ch_code.unsafe_to_char()
    if ch == '+' {
      result_bytes.push(b' ')
      i = i + 1
    } else if ch == '%' && i + 2 < len {
      // Try to parse hex digits
      let hex_start = i + 1
      let hex_end = i + 3
      let hex = substring(s, hex_start, hex_end)
      match parse_hex_byte(hex) {
        Some(byte) => {
          // Accumulate bytes for UTF-8 decoding
          result_bytes.push(byte)
          i = i + 3
        }
        None => {
          result_bytes.push(ch_code.to_byte())
          i = i + 1
        }
      }
    } else {
      result_bytes.push(ch_code.to_byte())
      i = i + 1
    }
  }
  // Convert accumulated bytes to UTF-8 string
  let arr : FixedArray[Byte] = FixedArray::make(result_bytes.length(), 0)
  for i = 0; i < result_bytes.length(); i = i + 1 {
    arr[i] = result_bytes[i]
  }
  try {
    @encoding/utf8.decode(Bytes::from_array(arr))
  } catch {
    _ => "" // Fallback: if decode fails, return empty string
  }
}

///|
/// Extract substring safely
fn substring(s : String, start : Int, end : Int) -> String {
  let mut result = ""
  for i = start; i < end && i < s.length(); i = i + 1 {
    result = result + s[i].unsafe_to_char().to_string()
  }
  result
}

///|
/// URL encode a string (percent encoding)
pub fn url_encode(s : String) -> String {
  let mut result = ""
  for ch in s {
    if is_unreserved(ch) {
      result = result + Char::to_string(ch)
    } else {
      // Encode as UTF-8 bytes and percent-encode each byte
      let char_str = Char::to_string(ch)
      let bytes = @encoding/utf8.encode(char_str)
      for i = 0; i < bytes.length(); i = i + 1 {
        let byte = bytes[i]
        result = result + "%" + byte_to_hex(byte)
      }
    }
  }
  result
}

///|
/// Check if a character is unreserved (safe for URI without encoding)
fn is_unreserved(ch : Char) -> Bool {
  match ch {
    'a'
    | 'b'
    | 'c'
    | 'd'
    | 'e'
    | 'f'
    | 'g'
    | 'h'
    | 'i'
    | 'j'
    | 'k'
    | 'l'
    | 'm'
    | 'n'
    | 'o'
    | 'p'
    | 'q'
    | 'r'
    | 's'
    | 't'
    | 'u'
    | 'v'
    | 'w'
    | 'x'
    | 'y'
    | 'z'
    | 'A'
    | 'B'
    | 'C'
    | 'D'
    | 'E'
    | 'F'
    | 'G'
    | 'H'
    | 'I'
    | 'J'
    | 'K'
    | 'L'
    | 'M'
    | 'N'
    | 'O'
    | 'P'
    | 'Q'
    | 'R'
    | 'S'
    | 'T'
    | 'U'
    | 'V'
    | 'W'
    | 'X'
    | 'Y'
    | 'Z'
    | '0'
    | '1'
    | '2'
    | '3'
    | '4'
    | '5'
    | '6'
    | '7'
    | '8'
    | '9'
    | '-'
    | '_'
    | '.'
    | '~' => true
    _ => false
  }
}

///|
/// Parse a hex byte from a two-character string
fn parse_hex_byte(hex : String) -> Byte? {
  if hex.length() != 2 {
    return None
  }
  let high = hex_char_to_value(hex[0].unsafe_to_char())
  let low = hex_char_to_value(hex[1].unsafe_to_char())
  match (high, low) {
    (Some(h), Some(l)) => Some((h * 16 + l).to_byte())
    _ => None
  }
}

///|
/// Convert a hex character to its numeric value
fn hex_char_to_value(ch : Char) -> Int? {
  match ch {
    '0' => Some(0)
    '1' => Some(1)
    '2' => Some(2)
    '3' => Some(3)
    '4' => Some(4)
    '5' => Some(5)
    '6' => Some(6)
    '7' => Some(7)
    '8' => Some(8)
    '9' => Some(9)
    'a' | 'A' => Some(10)
    'b' | 'B' => Some(11)
    'c' | 'C' => Some(12)
    'd' | 'D' => Some(13)
    'e' | 'E' => Some(14)
    'f' | 'F' => Some(15)
    _ => None
  }
}

///|
/// Convert a byte to hex string (uppercase)
fn byte_to_hex(byte : Byte) -> String {
  let high = (byte.to_int() >> 4) & 0xF
  let low = byte.to_int() & 0xF
  value_to_hex_char(high).to_string() + value_to_hex_char(low).to_string()
}

///|
/// Convert a value (0-15) to hex character
fn value_to_hex_char(value : Int) -> Char {
  match value {
    0 => '0'
    1 => '1'
    2 => '2'
    3 => '3'
    4 => '4'
    5 => '5'
    6 => '6'
    7 => '7'
    8 => '8'
    9 => '9'
    10 => 'A'
    11 => 'B'
    12 => 'C'
    13 => 'D'
    14 => 'E'
    15 => 'F'
    _ => '0'
  }
}

///|
/// Get the path component
pub fn Uri::path(self : Uri) -> String {
  self.path
}

///|
/// Get a query parameter value (first one if multiple)
pub fn Uri::get_query(self : Uri, key : String) -> String? {
  match self.query.get(key) {
    Some(values) => if values.length() > 0 { Some(values[0]) } else { None }
    None => None
  }
}

///|
/// Get all query parameter values for a key
pub fn Uri::get_query_all(self : Uri, key : String) -> Array[String] {
  match self.query.get(key) {
    Some(values) => values
    None => []
  }
}

///|
/// Get the fragment component
pub fn Uri::fragment(self : Uri) -> String? {
  self.fragment
}

///|
/// Convert URI back to string
pub fn Uri::to_string(self : Uri) -> String {
  self.raw
}

///|
/// Build a query string from a map
pub fn build_query_string(params : Map[String, Array[String]]) -> String {
  let mut result = ""
  let mut first = true
  for key, values in params {
    for value in values {
      if not(first) {
        result = result + "&"
      }
      first = false
      result = result + url_encode(key)
      if value.length() > 0 {
        result = result + "=" + url_encode(value)
      }
    }
  }
  result
}
