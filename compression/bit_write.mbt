///|
pub struct BitWriter {
  mut out : Array[Byte]
  mut bit_buff : UInt64
  mut bit_cnt : UInt
}

///|
/// Create a new BitWriter
pub fn bit_writer() -> BitWriter {
  BitWriter::{ out: Array::new(), bit_buff: 0, bit_cnt: 0U }
}

///|
/// Write low `n` bits of `value` in LSB-first order.
/// Debug constraint kept from Rust version: n <= 24.
pub fn write_bits(self : BitWriter, value : UInt, n : UInt) -> Unit {
  if n == 0U {
    return
  }

  // mask low n bits
  let mask : UInt = (1U << n.reinterpret_as_int()) - 1U
  let v : UInt64 = (value & mask).to_uint64()

  // append into bit_buf at current bit_cnt (LSB-first)
  self.bit_buff = self.bit_buff | (v << self.bit_cnt.reinterpret_as_int())
  self.bit_cnt = self.bit_cnt + n

  // emit bytes as long as we have >= 8 bits
  while self.bit_cnt >= 8U {
    let byte = (self.bit_buff & 0xFF).to_uint().to_byte()
    self.out.push(byte)
    self.bit_buff = self.bit_buff >> 8
    self.bit_cnt = self.bit_cnt - 8
  }
}

///|
/// Write little-endian 16-bit value (used for stored block LEN/NLEN).
/// Must be byte-aligned.
pub fn write_le16(self : BitWriter, v : UInt16) -> Unit {
  self.out.push((v & 0x00FF).to_uint().to_byte())
  self.out.push(((v >> 8).to_uint() & 0xFFU).to_byte())
}

///|
/// Write raw bytes directly (used by stored blocks), must be byte-aligned.
pub fn write_raw_bytes(self : BitWriter, bytes : Bytes) -> Unit {
  let n = bytes.length()
  let mut i = 0
  while i < n {
    self.out.push(bytes[i])
    i = i + 1
  }
}

///|
/// Flush remaining bits (if any) into one byte (LSB-first) and clear the bit buffer.
pub fn align_to_byte(self : BitWriter) -> Unit {
  if self.bit_cnt > 0U {
    let byte = (self.bit_buff & 0xFF).to_uint().to_byte()
    self.out.push(byte)
    self.bit_buff = 0
    self.bit_cnt = 0U
  }
}

///|
/// Take and clear all emitted bytes. 
/// Note: does not implicitly align (DEFLATE allows block tail to be non byte-aligned).
pub fn take_bytes(self : BitWriter) -> Bytes {
  // keep bit_buf as-is; we only move out the fully emitted bytes
  let out = Bytes::from_array(self.out)
  self.out = Array::new()
  out
}

///|
/// Test-only helper: align then take all bytes.
pub fn drain_all_aligned(self : BitWriter) -> Bytes {
  self.align_to_byte()
  self.take_bytes()
}
