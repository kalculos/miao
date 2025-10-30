///|
const FAST_BITS : Int = 9

///|
const FAST_SIZE : Int = 1 << FAST_BITS

///|
pub struct Huffman {
  slow : Array[(UInt16, Byte, UInt16)]
  fast : Array[Int]
}

///|
/// Construct a table from the code length (canonical definition in MSB space).
/// Internally we reverse the MSB codewords to LSB-first before entering tables.
/// Used for lit/len and dist of dynamic blocks.
pub fn from_code_lengths(
  lengths : Array[Byte],
) -> Huffman raise CompressionError {
  // Calculate the length of each code (1..15) and perform a validity check.
  let bl_count = Array::make(16, 0) // index = bits, value = count
  for l in lengths {
    if l > 0 {
      if l > 15 {
        raise CompressionError::InvalidHuffman
      }
      bl_count[l.to_int()] += 1
    }
  }

  // Calculate the canonical start code (MSB presentation space)
  // next_code[b] = the first code of length b
  let next_code = Array::make(16, 0)
  let mut code = 0
  for bits in 1..=15 {
    code = (code + bl_count[bits - 1]) << 1
    next_code[bits] = code
  }

  // Assign an MSB codeword to each symbol -> reverse to LSB-first -> collect into the slow table
  let slow : Array[(UInt16, Byte, UInt16)] = Array::new()
  for sym, len in lengths.iter() {
    if len != 0 {
      let b = len.to_int()
      let c = next_code[b]
      next_code[b] = c + 1
      let rc_u : UInt16 = revbits(c.reinterpret_as_uint(), len.to_uint()).to_uint16()
      slow.push((rc_u, len, sym.to_uint16()))
    }
  }

  // Build the fast table (size = 1 << FAST_BITS)
  let fast = Array::make(FAST_SIZE, 0)

  // To avoid aliasing issues, manually push new arrays during bucketing.
  let max_fast_len = if FAST_BITS < 15 { FAST_BITS } else { 15 }
  let buckets : Array[Array[(UInt16, Byte, UInt16)]] = Array::new()
  let mut i = 0
  while i <= max_fast_len {
    buckets.push(Array::new())
    i = i + 1
  }

  // Place the slow items into their respective buckets by length (only care about items <= FAST_BITS).
  let mut sidx = 0
  while sidx < slow.length() {
    let t = slow[sidx] // (rc, len, sym)
    let l = t.1.to_int()
    if l <= max_fast_len {
      buckets[l].push(t)
    }
    sidx = sidx + 1
  }

  // Fill in the code lengths from shortest to longest (write the shortest code first, 
  // then overwrite the longest code), ensuring the "longest prefix" takes effect.
  let mut l = 1
  while l <= max_fast_len {
    let bucket = buckets[l]
    let mut j = 0
    while j < bucket.length() {
      let t = bucket[j]
      let rc = t.0.to_int()
      let sym_tag = t.2.to_int()
      let fill = 1 << (FAST_BITS - l)
      let base = rc << (FAST_BITS - l)
      let tag = (l << 16) | sym_tag
      let mut k = 0
      while k < fill {
        fast[base + k] = tag
        k = k + 1
      }
      j = j + 1
    }
    l = l + 1
  }

  //
  Huffman::{ slow, fast }
}

///|
pub fn from_explicit_codes(
  codes_lsb : Array[UInt16],
  lens : Array[Byte],
) -> Huffman {
  let slow : Array[(UInt16, Byte, UInt16)] = Array::new()
  let total = codes_lsb.length()
  let mut s = 0
  while s < total {
    let l = lens[s]
    if l != 0 {
      slow.push((codes_lsb[s], l, s.to_uint16()))
    }
    s = s + 1
  }
  let fast = Array::make(FAST_SIZE, 0)
  for t in slow {
    let rc = t.0
    let len = t.1.to_int()
    let sym = t.2.to_int()
    if len <= FAST_BITS {
      let fill = 1 << (FAST_BITS - len)
      let base = rc.to_int() << (FAST_BITS - len)
      let tag = (len << 16) | sym
      let mut i = 0
      while i < fill {
        fast[base + i] = tag
        i = i + 1
      }
    }
  }
  Huffman::{ slow, fast }
}

///|
pub fn from_explicit_codes_dist(
  codes_lsb : Array[UInt16],
  lens : Array[Byte],
) -> Huffman {
  let slow : Array[(UInt16, Byte, UInt16)] = Array::new()
  let total = codes_lsb.length()
  let mut s = 0
  while s < total {
    let l = lens[s]
    if l != 0 {
      slow.push((codes_lsb[s], l, s.to_uint16()))
    }
    s = s + 1
  }
  let fast = Array::make(FAST_SIZE, 0)
  for t in slow {
    let rc = t.0
    let len = t.1.to_int()
    let sym = t.2.to_int()
    if len <= FAST_BITS {
      let fill = 1 << (FAST_BITS - len)
      let base = rc.to_int() << (FAST_BITS - len)
      let tag = (len << 16) | sym
      let mut i = 0
      while i < fill {
        fast[base + i] = tag
        i = i + 1
      }
    }
  }
  Huffman::{ slow, fast }
}

///|
pub fn decode(
  self : Huffman,
  br : BitReaderStream,
) -> UInt16? raise CompressionError {
  let mut acc : UInt = 0U
  let mut len : Int = 0
  while len < 15 {
    match br.read_bits(1) {
      Some(b) => {
        acc = acc | (b << len)
        len = len + 1
      }
      None => return None
    }

    //
    if len <= FAST_BITS {
      let mask = (1 << len) - 1
      let idx = (acc.reinterpret_as_int() & mask) << (FAST_BITS - len)
      let entry = self.fast[idx]
      if entry != 0 && ((entry >> 16) & 0xFF) == len {
        return Some((entry & 0xFFFF).to_uint16())
      }
    }

    //
    for t in self.slow {
      if t.1.to_int() == len && t.0.to_uint() == acc {
        return Some(t.2)
      }
    }
  }
  raise CompressionError::InvalidHuffman
}
