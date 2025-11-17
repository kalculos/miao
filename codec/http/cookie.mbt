///| HTTP Cookie Support

///|
/// Represents an HTTP cookie
pub struct Cookie {
  name : String
  value : String
  domain : String?
  path : String?
  expires : String?
  max_age : Int?
  secure : Bool
  http_only : Bool
  same_site : SameSite?
}

///|
/// SameSite attribute values
pub enum SameSite {
  Strict
  Lax
  None
} derive(Eq, Show)

///|
/// Create a new Cookie
pub fn Cookie::new(name : String, value : String) -> Cookie {
  {
    name,
    value,
    domain: None,
    path: None,
    expires: None,
    max_age: None,
    secure: false,
    http_only: false,
    same_site: None,
  }
}

///|
/// Set the domain
pub fn Cookie::with_domain(self : Cookie, domain : String) -> Cookie {
  { ..self, domain: Some(domain) }
}

///|
/// Set the path
pub fn Cookie::with_path(self : Cookie, path : String) -> Cookie {
  { ..self, path: Some(path) }
}

///|
/// Set max age in seconds
pub fn Cookie::with_max_age(self : Cookie, max_age : Int) -> Cookie {
  { ..self, max_age: Some(max_age) }
}

///|
/// Set expires
pub fn Cookie::with_expires(self : Cookie, expires : String) -> Cookie {
  { ..self, expires: Some(expires) }
}

///|
/// Set secure flag
pub fn Cookie::with_secure(self : Cookie, secure : Bool) -> Cookie {
  { ..self, secure, }
}

///|
/// Set HttpOnly flag
pub fn Cookie::with_http_only(self : Cookie, http_only : Bool) -> Cookie {
  { ..self, http_only, }
}

///|
/// Set SameSite attribute
pub fn Cookie::with_same_site(self : Cookie, same_site : SameSite) -> Cookie {
  { ..self, same_site: Some(same_site) }
}

///|
/// Serialize cookie to Set-Cookie header value
pub fn Cookie::to_set_cookie_string(self : Cookie) -> String {
  let mut result = self.name + "=" + self.value
  match self.domain {
    Some(domain) => result = result + "; Domain=" + domain
    None => ()
  }
  match self.path {
    Some(path) => result = result + "; Path=" + path
    None => ()
  }
  match self.expires {
    Some(expires) => result = result + "; Expires=" + expires
    None => ()
  }
  match self.max_age {
    Some(max_age) => result = result + "; Max-Age=" + max_age.to_string()
    None => ()
  }
  if self.secure {
    result = result + "; Secure"
  }
  if self.http_only {
    result = result + "; HttpOnly"
  }
  match self.same_site {
    Some(Strict) => result = result + "; SameSite=Strict"
    Some(Lax) => result = result + "; SameSite=Lax"
    Some(None) => result = result + "; SameSite=None"
    None => ()
  }
  result
}

///|
/// Parse a Cookie header value (format: "name1=value1; name2=value2")
pub fn parse_cookie_header(cookie_str : String) -> Map[String, String] {
  let result : Map[String, String] = Map::new()
  let pairs = cookie_str.split(";")
  for pair in pairs {
    let trimmed_view = pair.to_string().trim(chars=" \t")
    let trimmed = trimmed_view.to_string()
    match trimmed.find("=") {
      Some(pos) => {
        let name = substring_helper(trimmed, 0, pos)
        let value = substring_helper(trimmed, pos + 1, trimmed.length())
        result.set(name, value)
      }
      None => () // Skip malformed cookie
    }
  }
  result
}

///|
/// Parse a Set-Cookie header value into a Cookie
pub fn parse_set_cookie(set_cookie_str : String) -> Cookie? {
  let parts = set_cookie_str.split(";").collect()
  if parts.length() == 0 {
    return None
  }

  // First part is name=value
  let first = parts[0].to_string().trim(chars=" \t").to_string()
  let (name, value) = match first.find("=") {
    Some(pos) => {
      let n = substring_helper(first, 0, pos)
      let v = substring_helper(first, pos + 1, first.length())
      (n, v)
    }
    None => return None
  }
  let mut cookie = Cookie::new(name, value)

  // Parse attributes
  for i = 1; i < parts.length(); i = i + 1 {
    let attr = parts[i].to_string().trim(chars=" \t").to_string()
    match attr.find("=") {
      Some(pos) => {
        let attr_name = substring_helper(attr, 0, pos).to_lower()
        let attr_value = substring_helper(attr, pos + 1, attr.length())
        if attr_name == "domain" {
          cookie = cookie.with_domain(attr_value)
        } else if attr_name == "path" {
          cookie = cookie.with_path(attr_value)
        } else if attr_name == "expires" {
          cookie = cookie.with_expires(attr_value)
        } else if attr_name == "max-age" {
          let parsed = @strconv.parse_int(attr_value) catch { _ => continue }
          cookie = cookie.with_max_age(parsed)
        } else if attr_name == "samesite" {
          let lower_value = attr_value.to_lower()
          if lower_value == "strict" {
            cookie = cookie.with_same_site(Strict)
          } else if lower_value == "lax" {
            cookie = cookie.with_same_site(Lax)
          } else if lower_value == "none" {
            cookie = cookie.with_same_site(None)
          }
        }
      }
      None => {
        let lower_attr = attr.to_lower()
        if lower_attr == "secure" {
          cookie = cookie.with_secure(true)
        } else if lower_attr == "httponly" {
          cookie = cookie.with_http_only(true)
        }
      }
    }
  }
  Some(cookie)
}

///|
/// Helper to extract substring
fn substring_helper(s : String, start : Int, end : Int) -> String {
  let mut result = ""
  for i = start; i < end && i < s.length(); i = i + 1 {
    result = result + s[i].unsafe_to_char().to_string()
  }
  result
}
