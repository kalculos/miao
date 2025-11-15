///|
/// BufferSlice: non-expanding slice view over an existing buffer's backing array.
/// This file contains the BufferSlice type and its implementations.

///|
pub struct BufferSlice {
  priv buf_arr : FixedArray[Byte]
  priv start : Int
  priv end : Int
  priv mut ridx : Int
  priv mut widx : Int
}

///|
pub impl ByteSlice for BufferSlice with read(self, dst, off, len) {
  let readable = self.widx - self.ridx
  if readable <= 0 {
    return 0
  }
  let to_read = if len > readable { readable } else { len }
  self.buf_arr.blit_to(dst, len=to_read, src_offset=self.ridx, dst_offset=off)
  self.ridx += to_read
  to_read
}

pub impl ByteSlice for BufferSlice with read_byte(self) {
  if self.ridx >= self.widx {
    raise fail("BufferSlice is drained, no bytes available to read")
  }
  let byte = self.buf_arr[self.ridx]
  self.ridx += 1
  byte
}

pub impl ByteSlice for BufferSlice with write(self, src, off, len) {
  if len <= 0 {
    return 0
  }
  let available = self.end - self.widx
  if available <= 0 {
    return 0
  }
  let to_write = if len > available { available } else { len }
  src.blit_to(self.buf_arr, len=to_write, src_offset=off, dst_offset=self.widx)
  self.widx += to_write
  to_write
}

pub impl ByteSlice for BufferSlice with write_byte(self, byte) {
  if self.widx >= self.end {
    abort("BufferSlice overflow: cannot write byte beyond slice end")
  }
  self.buf_arr[self.widx] = byte
  self.widx += 1
}

pub impl ByteSlice for BufferSlice with ridx(self) {
  self.ridx
}

pub impl ByteSlice for BufferSlice with widx(self) {
  self.widx
}

pub impl ByteSlice for BufferSlice with readable_bytes(self) {
  self.widx - self.ridx
}

pub impl ByteSlice for BufferSlice with writable_bytes(self) {
  self.end - self.widx
}

pub impl ByteSlice for BufferSlice with slice(self, from_index, to_index) {
  // for BufferSlice, slice(from,to) accepts indices relative to this slice's readable region
  let readable = self.readable_bytes()
  guard from_index >= 0 && to_index <= readable && from_index <= to_index else {
    abort("Invalid slice range for BufferSlice")
  }
  let abs_start = self.ridx + from_index
  let abs_end = self.ridx + to_index
  let view = BufferSlice::{
    buf_arr: self.buf_arr,
    start: abs_start,
    end: abs_end,
    ridx: abs_start,
    widx: abs_end,
  }
  view as &ByteSlice
}

pub impl ByteSlice for BufferSlice with copy(self) {
  let len = self.widx - self.ridx
  let new_buf = HeapByteBuf::new(len)
  if len > 0 {
    self.buf_arr.blit_to(new_buf.array, len~, src_offset=self.ridx, dst_offset=0)
    new_buf.widx = len
  }
  new_buf as &Buffer
}

pub impl ByteSlice for BufferSlice with view_as_bytes(self) {
  self.buf_arr.unsafe_reinterpret_as_bytes()[self.ridx:self.widx].to_bytes()
}

pub impl ByteSlice for BufferSlice with to_bytes(self) {
  let len = self.readable_bytes()
  let new_array : FixedArray[Byte] = FixedArray::make(len, 0)
  self.buf_arr.blit_to(new_array, len~, src_offset=self.ridx, dst_offset=0)
  new_array.unsafe_reinterpret_as_bytes()
}

pub impl ByteSlice for BufferSlice with set_position(self, pos) {
  // pos is relative to the slice
  let slice_len = self.widx - self.ridx
  guard pos >= 0 && pos <= slice_len else {
    abort("Invalid position for BufferSlice")
  }
  self.ridx = self.start + pos
}

pub impl ByteSlice for BufferSlice with each_byte(self, f) {
  for i = self.ridx; i < self.widx; i = i + 1 {
    f(self.buf_arr[i])
  }
}

pub impl ByteSlice for BufferSlice with skip_n(self, bytes_at_most) {
  let to_skip = if bytes_at_most > self.readable_bytes() {
    self.readable_bytes()
  } else {
    bytes_at_most
  }
  self.ridx += to_skip
}

pub impl ByteSlice for BufferSlice with clear(self) {
  self.ridx = self.start
  self.widx = self.start
}

pub impl ByteSlice for BufferSlice with get_byte(self, idx) {
  // idx is relative to slice's start
  let abs = self.start + idx
  guard idx >= 0 && abs < self.widx else {
    abort("Index out of bounds for BufferSlice")
  }
  ()
}

pub impl ByteSlice for BufferSlice with transfer_to(self, dst) {
  let readable = self.readable_bytes()
  if readable <= 0 {
    return
  }
  let written = dst.write(self.buf_arr, self.ridx, readable)
  self.ridx += written
}

pub impl ByteSlice for BufferSlice with transfer_from(self, src) {
  let len = src.length()
  if len <= 0 {
    return 0
  }
  let available = self.end - self.widx
  if available <= 0 {
    return 0
  }
  let to_copy = if len > available { available } else { len }
  for i = 0; i < to_copy; i = i + 1 {
    self.buf_arr[self.widx + i] = src[i]
  }
  self.widx += to_copy
  to_copy
}

pub impl ByteSlice for BufferSlice with array(self) {
  None
}