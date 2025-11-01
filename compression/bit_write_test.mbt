///|
test "BitWriter: write exact 1 byte then align" {
  let bw = bit_writer()
  // write low 8 bits 0xA5; then align (no change for a full byte)
  bw.write_bits(0xA5U, 8U)

  // already flushed one full byte
  let out0 = bw.take_bytes()
  assert_eq(out0.length(), 1)
  assert_eq(out0[0], 0xA5)

  // nothing left; align does nothing
  bw.align_to_byte()
  let out1 = bw.take_bytes()
  assert_eq(out1.length(), 0)
}

///|
test "BitWriter: two full bytes" {
  let bw = bit_writer()
  bw.write_bits(0xCDU, 8U)
  bw.write_bits(0xEFU, 8U)
  let out = bw.take_bytes()
  assert_eq(out.length(), 2)
  assert_eq(out[0], 0xCD)
  assert_eq(out[1], 0xEF)
}

///|
test "BitWriter: partial then align" {
  let bw = bit_writer()
  // LSB-first 0b101 => 0x05 after align
  bw.write_bits(0b101U, 3U)
  let o0 = bw.take_bytes()
  // not aligned: nothing emitted yet
  assert_eq(o0.length(), 0)
  bw.align_to_byte()
  let o1 = bw.take_bytes()
  assert_eq(o1.length(), 1)
  assert_eq(o1[0], 0x05)
}

///|
test "BitWriter: cross-byte write (12 bits), align flushes the high nibble" {
  let bw = bit_writer()
  // value = 0x0B3C = 0b1011_0011_1100 (low 12 bits)
  // LSB-first:
  //  - first emitted byte (low 8 bits) = 0x3C
  //  - remaining 4 bits = 0x0B -> after align = 0x0B
  bw.write_bits(0x0B3CU, 12U)
  let o0 = bw.take_bytes()
  assert_eq(o0.length(), 1)
  assert_eq(o0[0], 0x3C)
  bw.align_to_byte()
  let o1 = bw.take_bytes()
  assert_eq(o1.length(), 1)
  assert_eq(o1[0], 0x0B)
}

///|
test "BitWriter: write_le16 is LE and requires alignment" {
  let bw = bit_writer()
  // ensure aligned
  bw.align_to_byte()

  // write 0x3412 -> bytes [0x12, 0x34]
  bw.write_le16(0x3412)
  let out = bw.take_bytes()
  assert_eq(out.length(), 2)
  assert_eq(out[0], 0x12)
  assert_eq(out[1], 0x34)
}

///|
test "BitWriter: write_raw_bytes appends verbatim when aligned" {
  let bw = bit_writer()
  bw.align_to_byte()
  bw.write_raw_bytes(Bytes::from_array([0xDE, 0xAD]))
  let out = bw.take_bytes()
  assert_eq(out.length(), 2)
  assert_eq(out[0], 0xDE)
  assert_eq(out[1], 0xAD)
}

///|
test "BitWriter: take_bytes does not implicitly align" {
  let bw = bit_writer()
  bw.write_bits(0b111U, 3U)
  // not aligned yet -> nothing flushed
  let out0 = bw.take_bytes()
  assert_eq(out0.length(), 0)

  // now align then take -> one byte with low 3 bits set
  bw.align_to_byte()
  let out1 = bw.take_bytes()
  assert_eq(out1.length(), 1)
  assert_eq(out1[0], 0b0000_0111)
}

///|
test "BitReaderStream: read_bits basic LSB-first correctness" {
  let br = bit_reader()
  // feed one byte: 0b1010_1100
  let _ = br.feed(Bytes::from_array([0b1010_1100]))

  // Read 4 bits: lowest 4 bits (LSB-first) -> 0b1100 = 12
  let v1 = br.read_bits(4U).unwrap()
  assert_eq(v1, 0b1100U)

  // Next 4 bits -> 0b1010 = 10
  let v2 = br.read_bits(4U).unwrap()
  assert_eq(v2, 0b1010U)

  // Now no bits left
  assert_true(!br.can_read())
}

///|
test "BitReaderStream: read_bits spanning multiple bytes" {
  let br = bit_reader()

  // bytes: [0b11110000, 0b00001111]
  let _ = br.feed(Bytes::from_array([0b1111_0000, 0b0000_1111]))

  // Read 12 bits total -> low 8 (first byte) + low 4 (second)
  let val = br.read_bits(12U).unwrap()

  // => 0b1111_1111_0000 = 0xFF0
  assert_eq(val, 0xFF0U)
}

///|
test "BitReaderStream: read_bit sequentially" {
  let br = bit_reader()

  // LSB sequence 10101010 reversed
  let _ = br.feed(Bytes::from_array([0b0101_0101]))

  // Read 8 bits one by one
  let bits : Array[Int] = Array::new()
  let mut i = 0
  while i < 8 {
    let b = br.read_bit().unwrap()
    bits.push(b.to_int())
    i = i + 1
  }

  // LSB-first sequence: [1,0,1,0,1,0,1,0]
  assert_eq(bits, [1, 0, 1, 0, 1, 0, 1, 0])
  assert_true(!br.can_read())
}

///|
test "BitReaderStream: align_to_byte discards remainder bits" {
  let br = bit_reader()
  let _ = br.feed(Bytes::from_array([0b1111_0000]))
  let _ = br.read_bits(3U)
  assert_true(br.can_read())
  br.align_to_byte()
  assert_true(!br.can_read())
}

///|
test "BitReaderStream: read_bits insufficient returns None" {
  let br = bit_reader()
  let _ = br.feed(Bytes::from_array([0b1111_0000]))

  //
  let val = br.read_bits(16U)
  assert_true(val is None)
}

///|
test "BitReaderStream: take_bytes works correctly" {
  let br = bit_reader()
  let _ = br.feed(Bytes::from_array([1, 2, 3, 4]))
  let part = br.take_bytes(3).unwrap()

  //
  assert_eq(part.length(), 3)
  assert_eq(part[0], 1)
  assert_eq(part[1], 2)
  assert_eq(part[2], 3)
  assert_eq(br.byte_available(), 1)
}

///|
test "BitReaderStream: can_read reacts to bits and fifo" {
  let br = bit_reader()
  assert_true(!br.can_read())

  //
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

///|
test "BitWriter <-> BitReaderStream round-trip: mixed lengths" {
  let bw = bit_writer()
  bw.write_bits(0b101U, 3U)
  bw.write_bits(0b11110U, 5U)
  bw.write_bits(0b1010101U, 7U)

  //
  bw.align_to_byte()
  let bytes = bw.take_bytes()

  //
  let br = bit_reader()
  ignore(br.feed(bytes))

  //
  let a = br.read_bits(3U).unwrap()
  let b = br.read_bits(5U).unwrap()
  let c = br.read_bits(7U).unwrap()

  //
  assert_eq(a, 0b101U)
  assert_eq(b, 0b11110U)
  assert_eq(c, 0b1010101U)

  //
  br.align_to_byte()
  assert_true(!br.can_read())
}

///|
test "BitWriter <-> BitReaderStream round-trip: many small writes across bytes" {
  let bw = bit_writer()
  bw.write_bits(0b1U, 1U)
  bw.write_bits(0b10U, 2U)
  bw.write_bits(0b011U, 3U)
  bw.write_bits(0b1010U, 4U)
  bw.write_bits(0b1U, 1U)
  bw.write_bits(0b00U, 2U)
  bw.write_bits(0b111U, 3U)
  bw.write_bits(0b0101U, 4U)
  bw.align_to_byte()
  let bytes = bw.take_bytes()

  //
  let br = bit_reader()
  ignore(br.feed(bytes))

  //
  let e1 = br.read_bits(1U).unwrap()
  let e2 = br.read_bits(2U).unwrap()
  let e3 = br.read_bits(3U).unwrap()
  let e4 = br.read_bits(4U).unwrap()
  let e5 = br.read_bits(1U).unwrap()
  let e6 = br.read_bits(2U).unwrap()
  let e7 = br.read_bits(3U).unwrap()
  let e8 = br.read_bits(4U).unwrap()

  //
  assert_eq(e1, 0b1U)
  assert_eq(e2, 0b10U)
  assert_eq(e3, 0b011U)
  assert_eq(e4, 0b1010U)
  assert_eq(e5, 0b1U)
  assert_eq(e6, 0b00U)
  assert_eq(e7, 0b111U)
  assert_eq(e8, 0b0101U)

  //
  br.align_to_byte()
  assert_true(!br.can_read())
}
