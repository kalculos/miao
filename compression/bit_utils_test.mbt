///|
fn mask_n(n : UInt) -> UInt {
  if n == 0U {
    0U
  } else {
    (1U << n.reinterpret_as_int()) - 1U
  }
}

///|
test "revbits basic example 1101 -> 1011 (n=4)" {
  assert_eq(revbits(0b1101U, 4U), 0b1011U)
}

///|
test "revbits zero -> zero for any n" {
  assert_eq(revbits(0U, 0U), 0U)
  assert_eq(revbits(0U, 1U), 0U)
  assert_eq(revbits(0U, 8U), 0U)
}

///|
test "revbits all ones stays all ones in n bits" {
  let n : UInt = 8U
  let all_ones = mask_n(n)
  assert_eq(revbits(all_ones, n), all_ones)
}

///|
test "revbits n=0 returns 0 (loop不执行)" {
  assert_eq(revbits(0xFFFF_FFFFU, 0U), 0U)
}

///|
test "revbits single lowest bit -> highest bit in window" {
  let n : UInt = 8U
  assert_eq(revbits(0b0000_0001U, n), 0b1000_0000U)
}

///|
test "revbits ignores bits above n (higher bits should not影响结果)" {
  // v 的第 8 位为 1，但 n=4，仅翻转低 4 位 0001 -> 1000
  assert_eq(revbits(0b1_0001U, 4U), 0b1000U)
}

///|
test "power-of-two position symmetry: revbits(1<<k, n) == 1<<(n-1-k)" {
  let n : UInt = 8U
  let mut k : UInt = 0U
  while k < n {
    let v = 1U << k.reinterpret_as_int()
    let got = revbits(v, n)
    let expect = 1U << (n.reinterpret_as_int() - 1 - k.reinterpret_as_int())
    assert_eq(got, expect)
    k = k + 1U
  }
}

///|
test "double reverse (involution) within n bits" {
  let n : UInt = 12U
  let samples = [0x000U, 0x001U, 0xABC_U, 0xFED_U, 0x1234U, 0xFFFFU]
  for v in samples {
    let got = revbits(revbits(v, n), n)
    assert_eq(got, v & mask_n(n))
  }
}

///|
test "matches bit-by-bit manual expectation (small n sanity)" {
  let n : UInt = 5U
  let v = 0b1_0110_1U
  let expect = 0b10110U
  assert_eq(revbits(v, n), expect)
}

///|
test "different n windows on same value" {
  let v = 0b1101_0110U
  assert_eq(revbits(v, 4U), 0b0110U)
  assert_eq(revbits(v, 8U), 0b0110_1011U)
}

///|
test "revbits only depends on low-n bits" {
  let v = 0b1101_0110U
  let n = 4U
  assert_eq(revbits(v, n), revbits(v & mask_n(n), n))
}

///|
test "pack_bits_lsb: exactly 8 bits (LSB-first)" {
  // bits: [1,0,1,0,0,1,0,1]
  // LSB-first means b0=1 is least significant bit.
  // => binary 0b10100101 = 0xA5
  let bits = [1, 0, 1, 0, 0, 1, 0, 1]
  let packed = pack_bits_lsb(bits)
  assert_eq(packed.length(), 1)
  assert_eq(packed[0], 0xA5)
}

///|
test "pack_bits_lsb: fewer than 8 bits" {
  // bits: [1,0,1]
  // => binary 0b00000101 = 5
  let bits = [1, 0, 1]
  let packed = pack_bits_lsb(bits)
  assert_eq(packed.length(), 1)
  assert_eq(packed[0], 0x05)
}

///|
test "pack_bits_lsb: multiple full bytes" {
  // first 8 bits [1,0,0,0,0,0,0,0] -> 0b00000001 = 0x01
  // next 8 bits [1,1,1,1,1,1,1,1] -> 0xFF
  let bits = [1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1]
  let packed = pack_bits_lsb(bits)
  assert_eq(packed.length(), 2)
  assert_eq(packed[0], 0x01)
  assert_eq(packed[1], 0xFF)
}

///|
test "pack_bits_lsb: ends with partial byte" {
  // total 12 bits, all 1
  // low 8 bits -> 0xFF
  // remaining 4 bits -> 0b00001111 = 0x0F
  let bits = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
  let packed = pack_bits_lsb(bits)
  assert_eq(packed.length(), 2)
  assert_eq(packed[0], 0xFF)
  assert_eq(packed[1], 0x0F)
}

///|
test "pack_bits_lsb: all zeros" {
  // all bits zero should produce zeroed bytes
  let bits = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  let packed = pack_bits_lsb(bits)
  assert_eq(packed.length(), 2) // 11 bits -> two bytes
  assert_eq(packed[0], 0x00)
  assert_eq(packed[1], 0x00)
}

///|
test "pack_bits_lsb: alternating bits 0,1,0,1,... (16 bits)" {
  // low byte  -> 0b10101010 = 0xAA
  // high byte -> 0b10101010 = 0xAA
  let bits = [0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1]
  let packed = pack_bits_lsb(bits)
  assert_eq(packed.length(), 2)
  assert_eq(packed[0], 0xAA)
  assert_eq(packed[1], 0xAA)
}
