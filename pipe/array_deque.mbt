///|
/// ArrayDeque is a double-ended queue implemented as a ring buffer.
/// It supports efficient push/pop operations at both ends.
struct ArrayDeque[T] {
  buf : FixedArray[T]
  mut head : Int  // read index
  mut tail : Int  // write index
  mut size : Int
}

///|
/// Create a new ArrayDeque with the given capacity and default value.
pub fn [T] ArrayDeque::new(capacity : Int, default : T) -> ArrayDeque[T] {
  guard capacity > 0
  ArrayDeque::{
    buf: FixedArray::make(capacity, default),
    head: 0,
    tail: 0,
    size: 0,
  }
}

///|
/// Returns the number of elements in the deque.
pub fn [T] ArrayDeque::length(self : ArrayDeque[T]) -> Int {
  self.size
}

///|
/// Returns the capacity of the deque.
pub fn [T] ArrayDeque::capacity(self : ArrayDeque[T]) -> Int {
  self.buf.length()
}

///|
/// Returns true if the deque is empty.
pub fn [T] ArrayDeque::is_empty(self : ArrayDeque[T]) -> Bool {
  self.size == 0
}

///|
/// Returns true if the deque is full.
pub fn [T] ArrayDeque::is_full(self : ArrayDeque[T]) -> Bool {
  self.size == self.buf.length()
}

///|
/// Returns the number of available slots in the deque.
pub fn [T] ArrayDeque::available(self : ArrayDeque[T]) -> Int {
  self.buf.length() - self.size
}

///|
/// Push a value to the back of the deque.
/// Returns true if successful, false if the deque is full.
pub fn [T] ArrayDeque::push_back(self : ArrayDeque[T], value : T) -> Bool {
  if self.is_full() {
    return false
  }
  self.buf[self.tail] = value
  self.tail = (self.tail + 1) % self.buf.length()
  self.size = self.size + 1
  true
}

///|
/// Pop a value from the front of the deque.
/// Returns Some(value) if successful, None if the deque is empty.
pub fn [T] ArrayDeque::pop_front(self : ArrayDeque[T]) -> Option[T] {
  if self.is_empty() {
    return None
  }
  let value = self.buf[self.head]
  self.head = (self.head + 1) % self.buf.length()
  self.size = self.size - 1
  Some(value)
}

///|
/// Peek at the front element without removing it.
pub fn [T] ArrayDeque::peek_front(self : ArrayDeque[T]) -> Option[T] {
  if self.is_empty() {
    return None
  }
  Some(self.buf[self.head])
}

///|
/// Read multiple elements from the front into a destination array.
/// Returns the number of elements actually read.
pub fn ArrayDeque::read_into(
  self : ArrayDeque[Byte],
  dst : FixedArray[Byte],
  dst_offset : Int,
  len : Int
) -> Int {
  let to_read = @cmp.minimum(len, self.size)
  if to_read == 0 {
    return 0
  }
  let buf_len = self.buf.length()
  // Handle wrap-around case
  if self.head + to_read > buf_len {
    let first_part = buf_len - self.head
    self.buf.blit_to(dst, len=first_part, src_offset=self.head, dst_offset=dst_offset)
    self.buf.blit_to(dst, len=to_read - first_part, src_offset=0, dst_offset=dst_offset + first_part)
  } else {
    self.buf.blit_to(dst, len=to_read, src_offset=self.head, dst_offset=dst_offset)
  }
  self.head = (self.head + to_read) % buf_len
  self.size = self.size - to_read
  to_read
}

///|
/// Write multiple elements to the back from a source array.
/// Returns the number of elements actually written.
pub fn ArrayDeque::write_from(
  self : ArrayDeque[Byte],
  src : FixedArray[Byte],
  src_offset : Int,
  len : Int
) -> Int {
  let to_write = @cmp.minimum(len, self.available())
  if to_write == 0 {
    return 0
  }
  let buf_len = self.buf.length()
  // Handle wrap-around case
  if self.tail + to_write > buf_len {
    let first_part = buf_len - self.tail
    src.blit_to(self.buf, len=first_part, src_offset=src_offset, dst_offset=self.tail)
    src.blit_to(self.buf, len=to_write - first_part, src_offset=src_offset + first_part, dst_offset=0)
  } else {
    src.blit_to(self.buf, len=to_write, src_offset=src_offset, dst_offset=self.tail)
  }
  self.tail = (self.tail + to_write) % buf_len
  self.size = self.size + to_write
  to_write
}

///|
/// Clear all elements from the deque.
pub fn [T] ArrayDeque::clear(self : ArrayDeque[T]) -> Unit {
  self.head = 0
  self.tail = 0
  self.size = 0
}

///|
/// Queue interface: peek at the front element.
/// Alias for peek_front().
pub fn [T] ArrayDeque::peek(self : ArrayDeque[T]) -> Option[T] {
  self.peek_front()
}

///|
/// Queue interface: try to pop from front (non-blocking).
/// Alias for pop_front().
pub fn [T] ArrayDeque::try_pop(self : ArrayDeque[T]) -> Option[T] {
  self.pop_front()
}

///|
/// Queue interface: try to push to back (non-blocking).
/// Alias for push_back().
pub fn [T] ArrayDeque::try_push(self : ArrayDeque[T], value : T) -> Bool {
  self.push_back(value)
}
