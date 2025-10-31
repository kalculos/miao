///|
/// Tests for HeapByteBuf constructor with different capacities
test "HeapByteBuf::new creates empty buffer with zero capacity" {
  let buf = HeapByteBuf::new(0)
  inspect(buf.readable_bytes(), content="0")
  inspect(buf.writable_bytes(), content="0")
  inspect(buf.ridx(), content="0")
  inspect(buf.widx(), content="0")
}

///|
test "HeapByteBuf::new creates buffer with specified capacity" {
  let buf = HeapByteBuf::new(100)
  inspect(buf.readable_bytes(), content="0")
  inspect(buf.writable_bytes(), content="100")
  inspect(buf.ridx(), content="0")
  inspect(buf.widx(), content="0")
}

///|
test "HeapByteBuf::wrapped_array creates buffer from array" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  inspect(buf.readable_bytes(), content="5")
  inspect(buf.ridx(), content="0")
  inspect(buf.widx(), content="5")
}

///|
test "HeapByteBuf::wrapped_bytes creates buffer from bytes" {
  let bytes = b"hello"
  let buf = HeapByteBuf::wrapped_bytes(bytes)
  inspect(buf.readable_bytes(), content="5")
  inspect(buf.ridx(), content="0")
  inspect(buf.widx(), content="5")
}

///|
/// Tests for read operations
test "read reads data from buffer" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  let dst : FixedArray[Byte] = FixedArray::make(3, 0)
  let bytes_read = buf.read(dst, 0, 3)
  inspect(bytes_read, content="3")
  inspect(dst[0].to_int(), content="1")
  inspect(dst[1].to_int(), content="2")
  inspect(dst[2].to_int(), content="3")
  inspect(buf.readable_bytes(), content="2")
}

///|
test "read returns 0 when buffer is empty" {
  let buf = HeapByteBuf::new(10)
  let dst : FixedArray[Byte] = FixedArray::make(5, 0)
  let bytes_read = buf.read(dst, 0, 5)
  inspect(bytes_read, content="0")
}

///|
test "read handles partial reads when less data available" {
  let arr : FixedArray[Byte] = [1, 2, 3]
  let buf = HeapByteBuf::wrapped_array(arr)
  let dst : FixedArray[Byte] = FixedArray::make(10, 0)
  let bytes_read = buf.read(dst, 0, 10)
  inspect(bytes_read, content="3")
}

///|
test "read_byte reads single byte" {
  let arr : FixedArray[Byte] = [42, 43, 44]
  let buf = HeapByteBuf::wrapped_array(arr)
  inspect(buf.read_byte().to_int(), content="42")
  inspect(buf.read_byte().to_int(), content="43")
  inspect(buf.readable_bytes(), content="1")
}

///|
/// Tests for write operations
test "write writes data to buffer" {
  let buf = HeapByteBuf::new(10)
  let src : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let bytes_written = buf.write(src, 0, 5)
  inspect(bytes_written, content="5")
  inspect(buf.readable_bytes(), content="5")
  inspect(buf.widx(), content="5")
}

///|
test "write expands capacity automatically" {
  let buf = HeapByteBuf::new(3)
  let src : FixedArray[Byte] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  let bytes_written = buf.write(src, 0, 10)
  inspect(bytes_written, content="10")
  inspect(buf.readable_bytes(), content="10")
}

///|
test "write returns 0 for zero length" {
  let buf = HeapByteBuf::new(10)
  let src : FixedArray[Byte] = [1, 2, 3]
  let bytes_written = buf.write(src, 0, 0)
  inspect(bytes_written, content="0")
}

///|
test "write_byte writes single byte" {
  let buf = HeapByteBuf::new(10)
  buf.write_byte(42)
  buf.write_byte(43)
  inspect(buf.readable_bytes(), content="2")
  inspect(buf.read_byte().to_int(), content="42")
  inspect(buf.read_byte().to_int(), content="43")
}

///|
test "write_byte expands capacity automatically" {
  let buf = HeapByteBuf::new(0)
  buf.write_byte(1)
  inspect(buf.readable_bytes(), content="1")
}

///|
/// Tests for slicing and copying
test "slice creates a view into the buffer" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  let slice = buf.slice(1, 4)
  inspect(slice.readable_bytes(), content="3")
  inspect(slice.read_byte().to_int(), content="2")
  inspect(slice.read_byte().to_int(), content="3")
  inspect(slice.read_byte().to_int(), content="4")
}

///|
test "copy creates deep copy" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  let copy = buf.copy()
  inspect(copy.readable_bytes(), content="5")
  // Modify original buffer
  ignore(buf.read_byte())
  // Copy should be unaffected
  inspect(copy.readable_bytes(), content="5")
}

///|
test "duplicate creates shared view" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  let dup = buf.duplicate()
  inspect(dup.readable_bytes(), content="5")
  inspect(dup.ridx(), content="0")
  inspect(dup.widx(), content="5")
}

///|
/// Tests for data conversion
test "to_bytes creates byte array from readable content" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  ignore(buf.read_byte()) // Read one byte
  let bytes = buf.to_bytes()
  inspect(bytes.length(), content="4")
  inspect(bytes[0].to_int(), content="2")
}

///|
test "view_as_bytes returns view of readable content" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  ignore(buf.read_byte()) // Read one byte
  let bytes = buf.view_as_bytes()
  inspect(bytes.length(), content="4")
  inspect(bytes[0].to_int(), content="2")
}

///|
/// Tests for position management
test "set_position changes read position" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  buf.set_position(3)
  inspect(buf.ridx(), content="3")
  inspect(buf.readable_bytes(), content="2")
  inspect(buf.read_byte().to_int(), content="4")
}

///|
test "skip_n skips specified bytes" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  buf.skip_n(2)
  inspect(buf.readable_bytes(), content="3")
  inspect(buf.read_byte().to_int(), content="3")
}

///|
test "skip_n with more than available skips all" {
  let arr : FixedArray[Byte] = [1, 2, 3]
  let buf = HeapByteBuf::wrapped_array(arr)
  buf.skip_n(10)
  inspect(buf.readable_bytes(), content="0")
}

///|
test "clear resets buffer" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  ignore(buf.read_byte())
  buf.clear()
  inspect(buf.ridx(), content="0")
  inspect(buf.widx(), content="0")
  inspect(buf.readable_bytes(), content="0")
}

///|
test "each_byte iterates over readable bytes" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  ignore(buf.read_byte()) // Skip first byte
  let mut sum = 0
  buf.each_byte(fn(b) { sum = sum + b.to_int() })
  inspect(sum, content="14") // 2 + 3 + 4 + 5
}

///|
/// Tests for Buffer-specific operations
test "shrink compacts buffer when ridx > 0" {
  let buf = HeapByteBuf::new(100)
  let src : FixedArray[Byte] = [1, 2, 3, 4, 5]
  ignore(buf.write(src, 0, 5))
  ignore(buf.read_byte())
  ignore(buf.read_byte())
  let result = buf.shrink()
  inspect(result, content="true")
  inspect(buf.ridx(), content="0")
  inspect(buf.readable_bytes(), content="3")
}

///|
test "shrink returns true when buffer is empty" {
  let buf = HeapByteBuf::new(100)
  let result = buf.shrink()
  inspect(result, content="true")
  inspect(buf.writable_bytes(), content="0")
}

///|
test "shrink reduces capacity when underutilized" {
  let buf = HeapByteBuf::new(1000)
  let src : FixedArray[Byte] = [1, 2, 3]
  ignore(buf.write(src, 0, 3))
  let result = buf.shrink()
  inspect(result, content="true")
  if buf.writable_bytes() >= 1000 {
    abort("Buffer should have shrunk")
  }
}

///|
test "shrink returns false when already optimal" {
  let buf = HeapByteBuf::new(64)
  let src : FixedArray[Byte] = FixedArray::make(50, 1)
  ignore(buf.write(src, 0, 50))
  let result = buf.shrink()
  inspect(result, content="false")
}

///|
test "ensure_writeable expands capacity if needed" {
  let buf = HeapByteBuf::new(10)
  buf.ensure_writeable(50)
  if buf.writable_bytes() < 50 {
    abort("Buffer should have expanded")
  }
}

///|
test "ensure_writeable does nothing if capacity sufficient" {
  let buf = HeapByteBuf::new(100)
  let initial_capacity = buf.writable_bytes()
  buf.ensure_writeable(50)
  inspect(buf.writable_bytes(), content="\{initial_capacity}")
}

///|
/// Tests for transfer operations
test "transfer_to transfers data to another buffer" {
  let src_buf = HeapByteBuf::new(10)
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  ignore(src_buf.write(data, 0, 5))
  let dst_buf = HeapByteBuf::new(10)
  src_buf.transfer_to(dst_buf as &Buffer)
  inspect(src_buf.readable_bytes(), content="0")
  inspect(dst_buf.readable_bytes(), content="5")
}

///|
test "transfer_from transfers data from BytesView" {
  let buf = HeapByteBuf::new(10)
  let bytes = b"hello"
  let view = bytes[0:5]
  let transferred = buf.transfer_from(view)
  inspect(transferred, content="5")
  inspect(buf.readable_bytes(), content="5")
}

///|
test "transfer_from expands capacity automatically" {
  let buf = HeapByteBuf::new(2)
  let bytes = b"hello world"
  let view = bytes[0:11]
  let transferred = buf.transfer_from(view)
  inspect(transferred, content="11")
  inspect(buf.readable_bytes(), content="11")
}

///|
/// Tests for edge cases
test "read and write on same buffer" {
  let buf = HeapByteBuf::new(10)
  let write_data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  ignore(buf.write(write_data, 0, 5))
  let read_data : FixedArray[Byte] = FixedArray::make(3, 0)
  ignore(buf.read(read_data, 0, 3))
  inspect(buf.readable_bytes(), content="2")
  // Write more data
  let more_data : FixedArray[Byte] = [6, 7, 8]
  ignore(buf.write(more_data, 0, 3))
  inspect(buf.readable_bytes(), content="5")
}

///|
test "multiple slices share same underlying array" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5]
  let buf = HeapByteBuf::wrapped_array(arr)
  let slice1 = buf.slice(0, 3)
  let slice2 = buf.slice(2, 5)
  
  inspect(slice1.readable_bytes(), content="3")
  inspect(slice2.readable_bytes(), content="3")
}

///|
test "copy_buffer creates independent buffer" {
  let buf = HeapByteBuf::new(10)
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  ignore(buf.write(data, 0, 5))
  let copy = buf.copy_buffer()
  ignore(buf.read_byte())
  inspect(buf.readable_bytes(), content="4")
  inspect(copy.readable_bytes(), content="5")
}

///|
test "large buffer expansion" {
  let buf = HeapByteBuf::new(0)
  let large_data : FixedArray[Byte] = FixedArray::make(10000, 42)
  let written = buf.write(large_data, 0, 10000)
  inspect(written, content="10000")
  inspect(buf.readable_bytes(), content="10000")
}

///|
test "HeapByteBuf::slice returns non-expanding BufferSlice (cannot write when full)" {
  let buf = HeapByteBuf::new(10)
  let data : FixedArray[Byte] = [1, 2, 3, 4, 5]
  ignore(buf.write(data, 0, 5))
  // Create an absolute slice covering the written region [0,5)
  let sl = buf.slice(0, 5)
  // The slice's writable_bytes should be 0 (widx == end)
  inspect(sl.writable_bytes(), content="0")
  // Attempt to write into the slice; should return 0 and not expand underlying buffer
  let extra : FixedArray[Byte] = [9, 9, 9]
  let wrote = sl.write(extra, 0, 3)
  inspect(wrote, content="0")
}
