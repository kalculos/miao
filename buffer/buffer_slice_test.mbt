///|
/// Tests for BufferSlice behavior

test "BufferSlice write is bounded and does not expand underlying buffer" {
  let arr : FixedArray[Byte] = [1, 2, 3, 4, 5, 6]
  let buf = HeapByteBuf::wrapped_array(arr)
  // Create a slice over absolute indices [1,4) -> elements 2,3,4 (size 3)
  let sl = buf.slice(1, 4)
  // Slice is full initially (ridx=start, widx=end) so writable_bytes == 0
  inspect(sl.readable_bytes(), content="3")
  inspect(sl.writable_bytes(), content="0")

  // Attempt to write into the slice: should write 0 bytes
  let src : FixedArray[Byte] = [9, 9, 9, 9]
  let written = sl.write(src, 0, 4)
  inspect(written, content="0")
}

///|
test "BufferSlice nested slice uses relative indices" {
  let arr : FixedArray[Byte] = [10, 11, 12, 13, 14]
  let buf = HeapByteBuf::wrapped_array(arr)
  // Absolute slice covering indices [1,5) -> 11,12,13,14
  let s1 = buf.slice(1, 5)
  inspect(s1.readable_bytes(), content="4")
  // Now take subslice relative to s1: [1,3) -> should map to absolute indices 2..3 => 12,13
  let s2 = s1.slice(1, 3)
  inspect(s2.readable_bytes(), content="2")
  inspect(s2.read_byte().to_int(), content="12")
  inspect(s2.read_byte().to_int(), content="13")
}
