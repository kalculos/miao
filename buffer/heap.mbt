///|
/// The threshold of switching resizing strategy from exponent to linear.
/// The idea is taken from Netty.
const THRESH : Int = 4 * 1024 * 1024

///|
let _EMPTY : FixedArray[Byte] = []

///|
pub struct HeapByteBuf {
  priv mut array : FixedArray[Byte]
  priv mut ridx : Int
  priv mut widx : Int
}
///|
pub fn HeapByteBuf::new(capacity : Int) -> HeapByteBuf {
  HeapByteBuf::{
    array: if capacity > 0 {
      FixedArray::make(capacity, 0)
    } else {
      _EMPTY
    },
    ridx: 0,
    widx: 0,
  }
}

///|
pub fn HeapByteBuf::wrapped_array(arr : FixedArray[Byte]) -> HeapByteBuf {
  HeapByteBuf::{ array: arr, ridx: 0, widx: arr.length() }
}

///|
pub fn HeapByteBuf::wrapped_bytes(arr : Bytes) -> HeapByteBuf {
  HeapByteBuf::{ array: hack_direct_farr(arr), ridx: 0, widx: arr.length() }
}

///|
fn hack_direct_farr(bytes : Bytes) -> FixedArray[Byte] = "%identity"

///|
fn calculate_new_capacity(current : Int, min_required : Int) -> Int {
  if min_required > THRESH {
    // Linear growth for large buffers
    let new_cap = (min_required / THRESH + 1) * THRESH
    return new_cap
  }
  // Exponential growth for small buffers
  let mut new_cap = @cmp.maximum(current, 1)
  while new_cap < min_required {
    new_cap = new_cap * 2
  }
  if new_cap <= 0 {
    new_cap = 64
  }
  new_cap
}

///|
fn HeapByteBuf::expand_capacity(self: HeapByteBuf, min_writable : Int) -> Unit {
  let current_cap = self.array.length()
  let min_required = self.widx + min_writable
  if min_required <= current_cap {
    return
  }
  let new_cap = calculate_new_capacity(current_cap, min_required)
  let new_array : FixedArray[Byte] = FixedArray::make(new_cap, 0)
  // Copy existing data
  self.array.blit_to(new_array, len=self.widx, src_offset=0, dst_offset=0)
  self.array = new_array
}

///|
pub impl ByteSlice for HeapByteBuf with read(self, dst, off, len) {
  let readable = self.readable_bytes()
  if readable <= 0 {
    return 0
  }
  let to_read = if len > readable { readable } else { len }
  self.array.blit_to(dst, len=to_read, src_offset=self.ridx, dst_offset=off)
  self.ridx += to_read
  to_read
}

///|
pub impl ByteSlice for HeapByteBuf with read_byte(self) {
  if self.ridx >= self.widx {
    raise fail("Buffer is drained, no bytes available to read")
  }
  let byte = self.array[self.ridx]
  self.ridx += 1
  byte
}

///|
pub impl ByteSlice for HeapByteBuf with write(self, src, off, len) {
  if len <= 0 {
    return 0
  }
  self.expand_capacity(len)
  src.blit_to(self.array, len~, src_offset=off, dst_offset=self.widx)
  self.widx += len
  len
}

///|
pub impl ByteSlice for HeapByteBuf with write_byte(self, byte) {
  self.expand_capacity(1)
  self.array[self.widx] = byte
  self.widx += 1
}

///|
pub impl ByteSlice for HeapByteBuf with ridx(self) {
  self.ridx
}

///|
pub impl ByteSlice for HeapByteBuf with widx(self) {
  self.widx
}

///|
pub impl ByteSlice for HeapByteBuf with readable_bytes(self) {
  self.widx - self.ridx
}

///|
pub impl ByteSlice for HeapByteBuf with writable_bytes(self) {
  self.array.length() - self.widx
}

///|
pub impl ByteSlice for HeapByteBuf with slice(self, from_index, to_index) {
  // from_index/to_index are absolute indices relative to the underlying array (0..widx)
  guard from_index >= 0 && to_index <= self.widx && from_index <= to_index else {
    abort(
      "Invalid slice range: [\{from_index}, \{to_index}) for buffer with widx=\{self.widx}",
    )
  }
  let view = BufferSlice::{
    buf_arr: self.array,
    start: from_index,
    end: to_index,
    ridx: from_index,
    widx: to_index,
  }
  view as &ByteSlice
}

///|
pub impl ByteSlice for HeapByteBuf with copy(self) {
  let len = self.widx - self.ridx
  let new_buf = HeapByteBuf::new(len)
  if len > 0 {
    self.array.blit_to(new_buf.array, len~, src_offset=self.ridx, dst_offset=0)
    new_buf.widx = len
  }
  new_buf as &Buffer
}

///|
pub impl ByteSlice for HeapByteBuf with view_as_bytes(self) {
  self.array.unsafe_reinterpret_as_bytes()[self.ridx:self.widx].to_bytes()
}

///|
pub impl ByteSlice for HeapByteBuf with to_bytes(self) {
  let len = self.readable_bytes()
  let new_array : FixedArray[Byte] = FixedArray::make(len, 0)
  self.array.blit_to(new_array, len~, src_offset=self.ridx, dst_offset=0)
  new_array.unsafe_reinterpret_as_bytes()
}

///|
pub impl ByteSlice for HeapByteBuf with set_position(self, pos) {
  guard pos >= 0 && pos <= self.widx else {
    abort("Invalid position: \{pos}, widx=\{self.widx}")
  }
  self.ridx = pos
}

///|
pub impl ByteSlice for HeapByteBuf with each_byte(self, f) {
  guard self.ridx < self.widx
  for i = self.ridx; i < self.widx; i = i + 1 {
    f(self.array[i])
  }
}

///|
pub impl ByteSlice for HeapByteBuf with skip_n(self, bytes_at_most) {
  let to_skip = if bytes_at_most > self.readable_bytes() {
    self.readable_bytes()
  } else {
    bytes_at_most
  }
  self.ridx += to_skip
}

///|
pub impl ByteSlice for HeapByteBuf with clear(self) {
  self.ridx = 0
  self.widx = 0
}

///|
pub impl ByteSlice for HeapByteBuf with get_byte(self, idx) {
  guard idx >= 0 && idx < self.widx else {
    abort("Index out of bounds: \{idx}, widx=\{self.widx}")
  }
  () // The signature in bytebuf.mbt is `get_byte(Self, idx : Int) -> Unit`
}

///|
pub impl ByteSlice for HeapByteBuf with transfer_to(self, dst) {
  let readable = self.readable_bytes()
  if readable <= 0 {
    return
  }
  let written = dst.write(self.array, self.ridx, readable)
  self.ridx += written
}

///|
pub impl ByteSlice for HeapByteBuf with transfer_from(self, src) {
  let len = src.length()
  if len <= 0 {
    return 0
  }
  self.expand_capacity(len)
  // Copy bytes from BytesView to the buffer
  for i = 0; i < len; i = i + 1 {
    self.array[self.widx + i] = src[i]
  }
  self.widx += len
  len
}

///|
pub impl Buffer for HeapByteBuf with duplicate(self) {
  let dup = HeapByteBuf::{ array: self.array, ridx: self.ridx, widx: self.widx }
  dup as &Buffer
}

///|
pub impl Buffer for HeapByteBuf with copy_buffer(self) {
  self.copy() as &Buffer
}

///|
pub impl Buffer for HeapByteBuf with shrink(self) {
  let readable = self.readable_bytes()
  if readable == 0 {
    self.array = _EMPTY
    self.ridx = 0
    self.widx = 0
    return true
  }
  if self.ridx > 0 {
    // Compact: move readable data to the beginning
    let new_array : FixedArray[Byte] = FixedArray::make(readable, 0)
    self.array.blit_to(
      new_array,
      len=readable,
      src_offset=self.ridx,
      dst_offset=0,
    )
    self.array = new_array
    self.ridx = 0
    self.widx = readable
    return true
  }
  // Already at the beginning, check if we can shrink capacity
  if self.widx < self.array.length() / 2 && self.array.length() > 64 {
    let new_array : FixedArray[Byte] = FixedArray::make(self.widx, 0)
    self.array.blit_to(new_array, len=self.widx, src_offset=0, dst_offset=0)
    self.array = new_array
    return true
  }
  false
}

///|
pub impl Buffer for HeapByteBuf with ensure_writeable(self, min_writable) {
  self.expand_capacity(min_writable)
}
