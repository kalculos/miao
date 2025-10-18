///|
pub struct Huffman {
  slow : Array[(UInt16, UInt16, UInt16)]
  fast : Array[UInt]
}

///|
pub fn from_code_lengths(lengths : Array[Byte]) -> Huffman? {
  None
}

///|
pub fn from_explicit_codes(
  codes_lsb : Array[UInt16],
  len : Array[Byte],
) -> Huffman? {
  None
}

///|
pub fn from_explicit_codes_dist(
  codes_lsb : Array[UInt16],
  len : Array[Byte],
) -> Huffman? {
  None
}

///|
pub fn decode(self : Huffman, bit_reader : Ref[BitReaderStream]) -> UInt16 {
  0
}
