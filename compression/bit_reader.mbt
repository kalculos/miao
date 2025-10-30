///|
pub struct BitReaderStream {
  mut fifo : Array[Byte]
  mut head : Int
  mut tail : Int
  mut cap : Int
  mut bit_buff : UInt64
  mut bit_cnt : UInt
}

///|
pub fn bit_reader() -> BitReaderStream {
  let cap = 4096
  BitReaderStream::{
    fifo: Array::make(cap, 0),
    head: 0,
    tail: 0,
    cap,
    bit_buff: 0,
    bit_cnt: 0U,
  }
}

///|
/// Current number of bytes stored in the ring buffer.
fn fifo_len(self : BitReaderStream) -> Int {
  if self.tail >= self.head {
    self.tail - self.head
  } else {
    self.cap - (self.head - self.tail)
  }
}

///|
/// Pop one byte from FIFO. Returns None if empty.
fn fifo_pop(self : BitReaderStream) -> Byte? {
  if self.head == self.tail {
    None
  } else {
    let b = self.fifo[self.head]
    self.head = (self.head + 1) % self.cap
    Some(b)
  }
}

///|
/// Ensure capacity for `extra` more bytes (including one sentinel slot),
/// compacting current content to [0..len) if we need to grow.
fn ensure_capacity(self : BitReaderStream, extra : Int) -> Unit {
  let need = self.fifo_len() + extra + 1
  if need <= self.cap {
    return
  }
  let mut new_cap = self.cap
  while new_cap < need {
    new_cap = new_cap * 2
  }

  // Move existing bytes out in order
  let v : Array[Byte] = Array::make(new_cap, 0)
  let mut i = 0
  let mut opt_b = self.fifo_pop()
  while opt_b is Some(b) {
    v[i] = b
    i = i + 1
    opt_b = self.fifo_pop()
  }
  self.fifo = v
  self.cap = new_cap
  self.head = 0
  self.tail = i
}

///|
/// Push as many bytes as possible into the ring buffer. Returns #pushed.
fn fifo_push(self : BitReaderStream, bytes : Bytes) -> Int {
  let n = bytes.length()
  self.ensure_capacity(n)
  let mut pushed = 0
  let mut idx = 0
  while idx < n {
    let next = (self.tail + 1) % self.cap
    if next == self.head {
      break
    } // full (kept 1-slot sentinel)
    self.fifo[self.tail] = bytes[idx]
    self.tail = next
    pushed = pushed + 1
    idx = idx + 1
  }
  pushed
}

///|
/// Feed bytes into the stream. Returns number of bytes accepted.
pub fn feed(self : BitReaderStream, input : Bytes) -> Int {
  self.fifo_push(input)
}

///|
/// Read `n` bits (1..=15) in LSB-first order. Returns None if not enough bits/bytes yet.
pub fn read_bits(self : BitReaderStream, n : UInt) -> UInt? {
  if n == 0U {
    return Some(0U)
  }

  // Fill bit_buf until we have at least n bits
  while self.bit_cnt < n {
    match self.fifo_pop() {
      Some(b) => {
        // push this byte at current bit_cnt (LSB-first)
        self.bit_buff = self.bit_buff |
          (b.to_uint64() << self.bit_cnt.reinterpret_as_int())
        self.bit_cnt = self.bit_cnt + 8U
      }
      None => return None
    }
  }
  let mask : UInt64 = (1 << n.reinterpret_as_int()) - 1
  let val : UInt = (self.bit_buff & mask).to_uint()
  self.bit_buff = self.bit_buff >> n.reinterpret_as_int()
  self.bit_cnt = self.bit_cnt - n
  Some(val)
}

///|
pub fn read_bit(self : BitReaderStream) -> Byte? {
  match self.read_bits(1U) {
    Some(v) => Some((v & 1U).to_byte())
    None => None
  }
}

///|
/// Align to next byte boundary by discarding up to 7 pending bits.
pub fn align_to_byte(self : BitReaderStream) -> Unit {
  let rem = self.bit_cnt % 8U
  if rem != 0U {
    ignore(self.read_bits(rem))
  }
}

///|
/// Whether there is at least one bit or byte available to read.
pub fn can_read(self : BitReaderStream) -> Bool {
  self.bit_cnt > 0U || self.fifo_len() > 0
}

///|
/// Number of whole bytes currently buffered (not counting bits in bit_buf).
pub fn byte_available(self : BitReaderStream) -> Int {
  self.fifo_len()
}

///|
/// Take exactly `n` bytes from FIFO if available. Returns None if insufficient.
pub fn take_bytes(self : BitReaderStream, n : Int) -> Bytes? {
  if self.fifo_len() < n {
    return None
  }
  let out = Array::new()
  let mut i = 0
  while i < n {
    match self.fifo_pop() {
      Some(b) => out.push(b)
      None => break
    }
    i = i + 1
  }
  Some(Bytes::from_array(out))
}
