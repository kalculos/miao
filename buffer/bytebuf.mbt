///|
pub(open) trait ByteSlice {
  ///| Returns the bytes actually written. <=0 if the buffer is drained
  read(Self, dst : FixedArray[Byte], off : Int, len : Int) -> Int
  read_byte(Self) -> Byte raise
  write(Self, src : FixedArray[Byte], off : Int, len : Int) -> Int
  write_byte(Self, Byte) -> Int
  ridx(Self) -> Int
  widx(Self) -> Int
  readable_bytes(Self) -> Int
  writable_bytes(Self) -> Int
  // create a copy of this buffer, which shares the same memory region with different ridx and widx.
  // The slice does not guarantee auto expansion.
  slice(Self, from_index : Int, to_index : Int) -> &ByteSlice
  /// Create a deep copy of this slice.
  copy_slice(Self) -> &Buffer
  view_as_bytes(Self) -> Bytes
  to_bytes(Self) -> Bytes
  set_position(Self, Int) -> Unit
  each_byte(Self, (Byte) -> Unit) -> Unit
  skip_n(Self, bytes_at_most : Int) -> Unit
  /// This method resets ridx and widx.
  clear(Self) -> Unit
  get_byte(Self, idx : Int) -> Unit
  transfer_to(Self, dst : &Buffer) -> Unit
  transfer_from(Self, src : BytesView) -> Int
}

///|
/// The difference of a buffer and a channel is that the buffer guarantees random access and data is 
/// always available. It also expands its capacity automatically.
pub(open) trait Buffer: ByteSlice {
  /// create a copy this buffer with same memory region, ridx and widx.
  /// It does not expands automatically.
  duplicate(Self) -> &Buffer
  /// Create a deep copy of this buffer.
  copy_buffer(Self) -> &Buffer
  /// Try to release unused spaces. Subsequent access to sank memories may cause an error 
  shrink(Self) -> Bool
  ensure_writeable(Self, Int) -> Unit
}
