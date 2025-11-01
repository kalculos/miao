///|
/// Reverse the lowest `n` bits of unsigned integer `v`.
///
/// Example:
/// revbits(0b1101U, 4U) -> 0b1011U
pub fn revbits(v : UInt, n : UInt) -> UInt {
  let mut result : UInt = 0U
  let mut i : UInt = 0U
  while i < n {
    // Extract bit i from v
    let bit : UInt = (v >> i.reinterpret_as_int()) & 1U
    // Place it in reversed position
    result = result |
      (bit << (n.reinterpret_as_int() - 1 - i.reinterpret_as_int()))
    i = i + 1
  }
  result
}

///|
/// Packs a sequence of bits (`0` or `1`) into a byte array using LSB-first order.
///
/// Each group of up to 8 bits is collected into one output byte,  
/// where the first bit in the input** becomes the **least significant bit (bit 0)* 
/// of the first byte, and so on.
pub fn pack_bits_lsb(bits : Array[Int]) -> Array[Byte] {
  let out : Array[Byte] = Array::new()
  let mut cur : Byte = 0
  let mut cnt : Int = 0
  for b in bits {
    if b != 0 {
      cur = cur | (1 << cnt)
    }
    cnt = cnt + 1
    if cnt == 8 {
      out.push(cur & 0xFF)
      cur = 0
      cnt = 0
    }
  }
  if cnt > 0 {
    out.push(cur & 0xFF)
  }
  out
}
