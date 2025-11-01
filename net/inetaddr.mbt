///|
pub(all) enum InetAddr {
  IPv4(host~ : Int)
  IPv6(msb~ : Int64, lsb~ : Int64)
} derive(Hash, Eq)

///|
pub fn InetAddr::from_ipv4(s : String) -> InetAddr raise {
  let parts = s.split(".").to_array()
  guard parts.length() == 4 else { raise fail("Invalid IPv4 address \{s}") }
  let nums = []
  for part in parts {
    try @strconv.parse_int(part) catch {
      err => raise fail("Couldn't parse \{part} as an byte. \{err}")
    } noraise {
      n => {
        guard n >= 0 && n <= 255 else {
          raise fail("Couldn't parse \{part} as an byte.")
        }
        nums.push(n)
      }
    }
  }
  let host = (nums[0] << 24) | (nums[1] << 16) | (nums[2] << 8) | nums[3]
  IPv4(host~)
}

///|
pub fn InetAddr::from_ipv6(s : String) -> InetAddr raise {
  // Handle standard IPv6 formats including :: compression
  // Examples: 2001:0db8:85a3:0:0:8a2e:370:7334, ::1, fe80::, ::ffff:192.0.2.1

  // Find :: position if it exists
  fn find_double_colon(str : String) -> Int? {
    let mut i = 0
    while i < str.length() - 1 {
      if str[i] == ':' && str[i + 1] == ':' {
        return Some(i)
      }
      i = i + 1
    }
    None
  }

  // Check for multiple :: occurrences
  fn has_multiple_double_colons(str : String) -> Bool {
    let mut count = 0
    let mut i = 0
    let mut prev_colon = false
    while i < str.length() {
      if str[i] == ':' {
        if prev_colon {
          count = count + 1
          if count > 1 {
            return true
          }
        }
        prev_colon = true
      } else {
        prev_colon = false
      }
      i = i + 1
    }
    false
  }

  guard not(has_multiple_double_colons(s)) else {
    raise fail("Invalid IPv6 Address: multiple :: found in \{s}")
  }
  let parts : Array[String] = match find_double_colon(s) {
    Some(idx) => {
      // Handle :: compression
      let left = if idx == 0 { "" } else { s[0:idx].to_string() }
      let right = if idx + 2 >= s.length() {
        ""
      } else {
        s[idx + 2:].to_string()
      }
      let left_parts = if left == "" {
        []
      } else {
        left.split(":").map(fn(sv) { sv.to_string() }).to_array()
      }
      let right_parts = if right == "" {
        []
      } else {
        right.split(":").map(fn(sv) { sv.to_string() }).to_array()
      }
      let missing_groups = 8 - left_parts.length() - right_parts.length()
      guard missing_groups >= 0 else {
        raise fail("Invalid IPv6 Address: too many groups in \{s}")
      }
      let result = []
      for part in left_parts {
        result.push(part)
      }
      let mut i = 0
      while i < missing_groups {
        result.push("0")
        i = i + 1
      }
      for part in right_parts {
        result.push(part)
      }
      result
    }
    None =>
      // No :: compression
      s.split(":").map(fn(sv) { sv.to_string() }).to_array()
  }
  guard parts.length() == 8 else {
    raise fail(
      "Invalid IPv6 Address: expected 8 groups, got \{parts.length()} in \{s}",
    )
  }
  let nums : Array[Int64] = []
  for part in parts {
    guard part != "" else {
      raise fail("Invalid IPv6 Address: empty group in \{s}")
    }
    try @strconv.parse_int64(part, base=16) catch {
      err => raise fail("Couldn't parse \{part} as a hex digit. \{err}")
    } noraise {
      n => {
        guard n >= 0 && n <= 0xFFFF else {
          raise fail(
            "Couldn't parse \{part} as a hex digit (out of range 0-FFFF).",
          )
        }
        nums.push(n)
      }
    }
  }
  let msb = (nums[0] << 48) | (nums[1] << 32) | (nums[2] << 16) | nums[3]
  let lsb = (nums[4] << 48) | (nums[5] << 32) | (nums[6] << 16) | nums[7]
  IPv6(msb~, lsb~)
}

///|
pub fn InetAddr::to_string(self : InetAddr) -> String {
  match self {
    IPv4(host~) => {
      let a = (host >> 24) & 0xFF
      let b = (host >> 16) & 0xFF
      let c = (host >> 8) & 0xFF
      let d = host & 0xFF
      "\{a}.\{b}.\{c}.\{d}"
    }
    IPv6(msb~, lsb~) => {
      let parts = [
        (msb >> 48) & 0xFFFF,
        (msb >> 32) & 0xFFFF,
        (msb >> 16) & 0xFFFF,
        msb & 0xFFFF,
        (lsb >> 48) & 0xFFFF,
        (lsb >> 32) & 0xFFFF,
        (lsb >> 16) & 0xFFFF,
        lsb & 0xFFFF,
      ]
      parts.map(fn(x) { int64_to_hex(x).to_lower() }).join(":")
    }
  }
}

///|
pub fn int64_to_hex(n : Int64) -> String {
  if n == 0 {
    return "0"
  }
  let mut result = ""
  let mut num = n
  while num != 0 {
    let rem = num % 16
    let digit = if rem < 10 {
      Int::to_char('0'.to_int() + rem.to_int())
    } else {
      Int::to_char('A'.to_int() + (rem - 10).to_int())
    }
    result = digit.unwrap().to_string() + result
    num = num / 16
  }
  result
}

///|
pub impl Show for InetAddr with output(self, logger) {
  logger.write_string(self.to_string())
}
