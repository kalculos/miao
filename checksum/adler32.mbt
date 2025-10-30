///|
/// Largest prime less than 2^16 (used as Adler-32 modulus)
const MODULUS : UInt = 65521U

///|
/// Block size per zlib reference implementation
const MAX_BLOCK_SIZE : Int = 5552

///|
/// Compute Adler-32 checksum for given byte array
pub fn adler32(bytes : Array[Byte], initial_value? : UInt) -> UInt {
  // Initial Adler state: low 16 bits = A, high 16 bits = B
  let initial = initial_value.unwrap_or(1U)
  let mut sum_low : UInt = initial & 0xFFFFU
  let mut sum_high : UInt = (initial >> 16) & 0xFFFFU
  let total_length = bytes.length()
  let mut byte_index = 0
  while byte_index < total_length {
    // Process data in chunks to avoid integer overflow
    let block_length = @cmp.minimum(MAX_BLOCK_SIZE, total_length - byte_index)
    let mut block_offset = 0
    while block_offset < block_length {
      let byte_value : UInt = bytes[byte_index + block_offset].to_uint()
      sum_low = sum_low + byte_value
      sum_high = sum_high + sum_low
      block_offset = block_offset + 1
    }

    // Modulo operation once per block for efficiency
    sum_low = sum_low % MODULUS
    sum_high = sum_high % MODULUS
    byte_index = byte_index + block_length
  }
  (sum_high << 16) | sum_low
}
