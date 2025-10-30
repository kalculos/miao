///|
const FAST_BITS : Int = 9

///|
const FAST_SIZE : Int = 1 << FAST_BITS

///|
fn bls(xs : Array[Int]) -> Array[Byte] {
  let a = Array::new()
  for x in xs {
    a.push(x.to_byte())
  }
  a
}

///|
fn find_slow_entry(h : Huffman, sym : UInt16) -> (UInt16, Byte, UInt16)? {
  for t in h.slow {
    if t.2 == sym {
      return Some(t)
    }
  }
  None
}

///|
fn slow_longest_prefix(h : Huffman, idx : Int) -> (Int, Int)? {
  let mut best_len = -1
  let mut best_sym = -1
  for t in h.slow {
    let len = t.1.to_int()
    if len <= 0 {
      continue
    }
    if len > FAST_BITS {
      continue
    }

    //
    if idx >> (FAST_BITS - len) == t.0.to_int() {
      if len > best_len {
        best_len = len
        best_sym = t.2.to_int()
      }
    }
  }
  if best_len >= 0 {
    Some((best_len, best_sym))
  } else {
    None
  }
}

///|
test "huffman from_code_lengths: 4 symbols, all len=2" {
  //
  let lengths = bls([2, 2, 2, 2])
  let h = from_code_lengths(lengths)

  //
  let expect_rc = [0U, 2U, 1U, 3U]
  let mut sym : UInt16 = 0
  while sym < 4 {
    let t = find_slow_entry(h, sym).unwrap()
    assert_eq(t.1, 2U.to_byte())
    assert_eq(t.2, sym)
    assert_eq(t.0.to_uint(), expect_rc[sym.to_int()])
    sym = sym + 1
  }

  //
  if 2 <= FAST_BITS {
    let mut sym2 : UInt16 = 0
    while sym2 < 4 {
      let rc = expect_rc[sym2.to_int()]
      let fill = 1 << (FAST_BITS - 2)
      let base = rc << (FAST_BITS - 2)
      let tag = (2 << 16) | sym2.to_int()
      let mut i = 0
      while i < fill {
        assert_eq(h.fast[base.reinterpret_as_int() + i], tag)
        i = i + 1
      }
      sym2 = sym2 + 1
    }
  }
}

///|
test "huffman from_code_lengths: mixed lens 1,3,3,2" {
  let lengths = bls([1, 3, 3, 2])
  let h = from_code_lengths(lengths)

  // bl_count: L1=1, L2=1, L3=2
  // start_code[1]=0b0, start_code[2]=0b10, start_code[3]=0b110
  // and assign c sequentially, and reverse LSB-first to rc:
  //  sym0(len1): c=0b0   -> rc=0b0   (0)
  //  sym1(len3): c=0b110 -> rc=0b011 (3)
  //  sym2(len3): c=0b111 -> rc=0b111 (7)
  //  sym3(len2): c=0b10  -> rc=0b01  (1)
  let expect = [
    (0U, 1U, 0U), // (rc,len,sym)
    (3U, 3U, 1U),
    (7U, 3U, 2U),
    (1U, 2U, 3U),
  ]

  //
  let mut k = 0
  while k < expect.length() {
    let (erc, elen, esym) = expect[k]
    let t = find_slow_entry(h, esym.to_uint16()).unwrap()
    assert_eq(t.1, elen.to_byte())
    assert_eq(t.2.to_uint(), esym)
    assert_eq(t.0.to_uint(), erc)
    k = k + 1
  }

  //
  let mut idx = 0
  while idx < FAST_SIZE {
    match slow_longest_prefix(h, idx) {
      Some((elen, esym)) => {
        let expect_tag = (elen << 16) | esym
        assert_eq(h.fast[idx], expect_tag)
      }
      None => assert_eq(h.fast[idx], 0)
    }
    idx = idx + 1
  }
}

///|
test "huffman from_code_lengths: only symbols with len>0 enter tables" {
  let lengths = bls([0, 0, 3, 0, 0, 0])
  let h = from_code_lengths(lengths)
  assert_eq(h.slow.length(), 1)
  let t = h.slow[0]
  assert_eq(t.2.to_uint(), 2U)
  assert_eq(t.1, 3U.to_byte())
  if 3 <= FAST_BITS {
    let fill = 1 << (FAST_BITS - 3)
    let base = t.0.to_int() << (FAST_BITS - 3)
    let tag = (3 << 16) | 2
    let mut i = 0
    while i < fill {
      assert_eq(h.fast[base + i], tag)
      i = i + 1
    }
  }
}
