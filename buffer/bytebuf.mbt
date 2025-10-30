///| A bytebuf has a known size and growing capacity as needed. It guarantees random accesses and seeking is always available, 
/// and may accept advice from discard_read_bytes() and shrink(). It can be backed by alternatives to byte arrays, like Arena or 
/// multiple bytebufs that act as a composition.
pub(open) trait ByteBuf {
  len(Self) -> Int
  is_empty(Self) -> Bool = _
  to_bytes(Self) -> Bytes
  ///| This will reset the reader and writer index.
  /// The content will no longer be accessible.
  clear(Self) -> Unit
  ///| Mark and return the current reader index.
  /// You can reset to this index later.
  /// The returned index may not guarantee the absolute position in the byte stream.
  /// and the position should be invalidated once #reset is used. 
  mark(Self) -> Int
  ///| Reset the reader index to the previously marked index.
  /// If no index was marked, this will reset the reader index to 0.
  reset(Self) -> Unit
  ///| Get the current readerIndex.
  position(Self) -> Int
  ///| Discard the read bytes and move the unread bytes to the beginning.
  /// This will reset the reader index to 0 and adjust the writer index accordingly.
  /// This is useful when you want to free up space in the buffer. It creates a new underlying storage and copies the content.
  /// Marks will lose if they are earlier than the reader index.
  discard_read_bytes(Self) -> Unit
  ///| Shrink the capacity of the buffer to fit the current content.
  /// This will not affect the reader and writer indices.
  /// This method creates a new underlying storage and copies the content.
  shrink(Self) -> Unit 
  ///| Create a slice of the buffer from start to end.
  /// The new buffer will have its own reader and writer indices.
  /// The content will be shared between the two buffers.
  /// Params:
  /// start: should be greater than or equals to the current readerIndex
  /// length: should be lower than or equals to the current writerIndex.
  slice(Self, start : Int, length : Int) -> &ByteBuf
  /// Make an attempt to copy an amount of bytes to the destinated bytebuf.
  /// This also increases reader index.
  /// Returns actually copied bytes. -1 if *this* bytebuf is at EOF
  transfer_to(Self, dst: &ByteBuf, length: Int) -> Int
  /// -- WRITER --
    ///| Remaining spaces we can write without resizing the underlying structure.
  capacity(Self) -> Int

  ///| Write some bytes into the destination.
  /// The buffer will increase its capacity if needed.
  write_bytes(Self, Bytes) -> Unit
  ///| Write bytes from a fixed array.
  write_array(Self, FixedArray[Byte], off: Int, len: Int) -> Unit = _
  write_byte(Self, Byte) -> Unit
  write_int(Self, Int) -> Unit = _
  write_int16(Self, Int16) -> Unit = _
  write_int64(Self, Int64) -> Unit = _
  write_uint(Self, UInt) -> Unit = _
  write_uint16(Self, UInt16) -> Unit = _
  write_uint64(Self, UInt64) -> Unit = _
  write_int_le(Self, Int) -> Unit = _
  write_int16_le(Self, Int16) -> Unit = _
  write_int64_le(Self, Int64) -> Unit = _
  write_uint_le(Self, UInt) -> Unit = _
  write_uint16_le(Self, UInt16) -> Unit = _
  write_uint64_le(Self, UInt64) -> Unit = _
  write_float(Self, Float) -> Unit = _
  write_float_le(Self, Float) -> Unit = _
  write_double(Self, Double) -> Unit = _
  write_double_le(Self, Double) -> Unit = _

  /// -- READER --
  remaining(Self) -> Int
  has_remaining(Self) -> Bool = _
  /// This method raises if we cannot read exactly %len bytes.
  read_bytes(Self, len : Int) -> Bytes raise
  /// This method returns an empty Bytes if had no remaining bytes. 
  /// Otherwise, try to read bytes as much as possible but not greater than len
  read_bytes_most(Self, len: Int) -> Bytes = _
  /// Returns the number of bytes read. -1 if cannot read to dst
  read(Self, dst: FixedArray[Byte], off: Int, len: Int) -> Int = _
  read_int(Self) -> Int raise = _
  read_int_le(Self) -> Int raise = _
  read_int16(Self) -> Int16 raise = _
  read_int16_le(Self) -> Int16 raise = _
  read_int64(Self) -> Int64 raise = _
  read_int64_le(Self) -> Int64 raise = _
  read_byte(Self) -> Byte raise = _
  read_uint(Self) -> UInt raise = _
  read_uint_le(Self) -> UInt raise = _
  read_uint16(Self) -> UInt16 raise = _
  read_uint16_le(Self) -> UInt16 raise = _
  read_uint64(Self) -> UInt64 raise = _
  read_uint64_le(Self) -> UInt64 raise = _
  read_float(Self) -> Float raise = _ 
  read_float_le(Self) -> Float raise = _
  read_double(Self) -> Double raise = _
  read_double_le(Self) -> Double raise = _
}