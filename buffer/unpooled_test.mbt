///|
test "test factories" {
  let buf = @buffer.make_unpooled_from_array([1, 2, 3, 4])
  inspect(
    buf.to_bytes(),
    content=(
      #|b"\x01\x02\x03\x04"
    ),
  )
  let buf = @buffer.make_unpooled(10)
  inspect(
    buf.to_bytes(),
    content=(
      #|b""
    ),
  )
  let buf = @buffer.make_unpooled_from_bytes(b"\x01\x02\x03\x04")
  inspect(
    buf.to_bytes(),
    content=(
      #|b"\x01\x02\x03\x04"
    ),
  )
}

///|
test "test heapbytebuf operations" {
  test_bytebuf_op(@buffer.make_unpooled(10))
  //todo discard_read_bytes and shrink
}

///|
fn test_bytebuf_op(buf : &ByteBuf) -> Unit raise {

  // test basic read/write and is_empty, len, remaining
  assert_true(buf.is_empty(), msg="buf should be empty initially")
  buf.write_byte(1)
  assert_false(buf.is_empty(), msg="buf should not be empty after write_byte")
  assert_eq(buf.len(), 1, msg="buf length should be 1 after write_byte")
  assert_eq(
    buf.remaining(),
    1,
    msg="buf remaining should be 1 after write_byte",
  )
  assert_eq(buf.read_byte(), 1, msg="read_byte should return 1")
  assert_true(buf.is_empty(), msg="buf should be empty after read_byte")
  buf.write_byte(1)
  buf.write_byte(2)
  let markPos = buf.mark()
  buf.write_byte(3)
  assert_eq(buf.read_byte(), 1)
  assert_eq(buf.position() - markPos, 1)
  buf.reset()
  assert_eq(buf.read_byte(), 1)
  assert_eq(buf.read_byte(), 2)
  assert_true(buf.len() == 1)

  // test discard and shrink
  let _ = buf.mark()
  let expect = buf.read_byte()
  buf.reset()
  buf.discard_read_bytes()
  buf.shrink()
  assert_eq(
    buf.read_byte(),
    expect,
    msg="discard and shrink should not change the content",
  )

  // test read but the buf is end
  assert_true(buf.is_empty(), msg="buf should be empty now")
  assert_true(
    (try? buf.read_byte()) is Err,
    msg="read_byte should return None when empty",
  )

  // test write but cannot fit
  buf.clear()
  buf.write_bytes([1, 2, 3, 4, 5])
  buf.shrink()
  buf.write_byte(6)

  //test discard but the mark is later than readerIndex
  assert_eq(buf.read_bytes(3), Bytes::from_array([1, 2, 3]))
  let _ = buf.mark()
  buf.discard_read_bytes()
  buf.reset()
  assert_eq(buf.read_bytes(3), Bytes::from_array([4, 5, 6]))
  buf.clear()
  buf.discard_read_bytes() // should do nothing
  return
}

///|
test "test slice" {
  let buf = @buffer.make_unpooled_from_array([1, 2, 3, 4, 5])
  assert_eq(buf.to_bytes(), Bytes::from_array([1, 2, 3, 4, 5]))
  let slice = buf.slice(1, 3)
  assert_eq(slice.to_bytes(), Bytes::from_array([2, 3, 4]))
  assert_eq(slice.len(), 3)
  assert_eq(slice.read_byte(), 2)
  assert_eq(slice.len(), 2)
  slice.write_bytes([6, 7])
  assert_eq(slice.to_bytes(), Bytes::from_array([3, 4, 6, 7]))
  assert_eq(buf.to_bytes(), Bytes::from_array([1, 2, 3, 4, 6]))
  assert_eq(slice.read_bytes(2), Bytes::from_array([3, 4]))
}

///|
test "example" {
  let buf = @buffer.make_unpooled(10)
  buf.write_int_le(0x01020304)
  buf.write_int(0x05060708)
  assert_eq(buf.len(), 8)
  assert_eq(buf.read_int_le(), 0x01020304)
  assert_eq(buf.read_int(), 0x05060708)
}

///|
test "transfer to" {
  let buf = @buffer.make_unpooled_from_array([1, 2, 3, 4, 5, 6, 7, 8])
  let buf_to_transfer = @buffer.make_unpooled(0)
  let transferred = buf.transfer_to(buf_to_transfer,10)
  assert_eq(transferred, 8)
  let expect =
    #|b"\x01\x02\x03\x04\x05\x06\x07\x08"
  inspect(buf_to_transfer.read_bytes(8), content=expect)
  let i = buf.transfer_to(buf_to_transfer, 100)
  assert_eq(i, -1)  
}
