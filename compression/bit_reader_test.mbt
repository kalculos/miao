test "bit_reader: read_bits basic LSB-first correctness" {
  let br = bit_reader()
  // feed one byte: 0b1010_1100
  let _ = br.feed(Bytes::from_array([0b1010_1100.to_byte()]))

  // Read 4 bits: should read lowest 4 bits (LSB-first) -> 0b1100 = 12
  let v1 = br.read_bits(4U).unwrap()
  assert_eq(v1, 0b1100U)

  // Next 4 bits: remaining bits -> 0b1010 = 10
  let v2 = br.read_bits(4U).unwrap()
  assert_eq(v2, 0b1010U)

  // Now no bits left
  assert_true(!br.can_read())
}

test "bit_reader: read_bits spanning multiple bytes" {
  let br = bit_reader()
  // bytes: [0b11110000, 0b00001111]
  let _ = br.feed(Bytes::from_array([0b1111_0000.to_byte(), 0b0000_1111.to_byte()]))

  // Read 12 bits total -> should read low 8 (from first) + low 4 (from second)
  let val = br.read_bits(12U).unwrap()
  // LSB-first: first byte low 8 bits = 0b11110000
  // next 4 bits from next byte = 0b1111
  // => combined (lower 12 bits) = 0b1111_1111_0000 = 0xFF0
  assert_eq(val, 0xFF0U)
}

test "bit_reader: read_bit sequentially" {
  let br = bit_reader()
  let _ = br.feed(Bytes::from_array([0b0101_0101.to_byte()])) // LSB-first pattern 10101010 reversed
  // Read 8 bits one by one
  let bits: Array[Int] = Array::new()
  let mut i = 0
  while i < 8 {
    let b = br.read_bit().unwrap()
    bits.push(b.to_int())
    i = i + 1
  }
  // LSB-first sequence: [1,0,1,0,1,0,1,0]
  assert_eq(bits, [1,0,1,0,1,0,1,0])
  assert_true(!br.can_read())
}

test "bit_reader: align_to_byte discards remainder bits" {
  let br = bit_reader()
  // feed one byte 0b1111_0000
  let _ = br.feed(Bytes::from_array([0b1111_0000.to_byte()]))
  // read 3 bits first
  let _ = br.read_bits(3U)
  assert_true(br.can_read())
  // align
  br.align_to_byte()
  // now bit buffer empty
  assert_true(!br.can_read())
}

test "bit_reader: read_bits insufficient returns None" {
  let br = bit_reader()
  // feed one byte only
  let _ = br.feed(Bytes::from_array([0b1111_0000.to_byte()]))
  // Try reading 16 bits -> not enough
  let val = br.read_bits(16U)
  assert_true(val is None)
}

test "bit_reader: take_bytes works correctly" {
  let br = bit_reader()
  let _ = br.feed(Bytes::from_array([1, 2, 3, 4]))
  let part = br.take_bytes(3).unwrap()
  assert_eq(part.length(), 3)
  assert_eq(part[0], 1)
  assert_eq(part[1], 2)
  assert_eq(part[2], 3)
  assert_eq(br.byte_available(), 1)
}

test "bit_reader: can_read reacts to bits and fifo" {
  let br = bit_reader()
  assert_true(!br.can_read())
  let _ = br.feed(Bytes::from_array([0xAB]))
  assert_true(br.can_read())
  // read part of it
  let _ = br.read_bits(4U)
  // still has remaining bits
  assert_true(br.can_read())
  // read remaining
  let _ = br.read_bits(4U)
  assert_true(!br.can_read())
}
