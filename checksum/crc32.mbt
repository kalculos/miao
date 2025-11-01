///|
/// Polynomial for standard IEEE CRC-32
const CRC32_POLYNOMIAL : UInt = 0xEDB88320U

///|
/// Generate a 256-entry CRC32 lookup table
pub fn generate_crc32_table() -> Array[UInt] {
  let table = Array::make(256, 0U)
  for table_index in 0..<256 {
    let mut crc_value = table_index.reinterpret_as_uint()
    for _ in 0..<8 {
      crc_value = if (crc_value & 1U) != 0U {
        (crc_value >> 1) ^ CRC32_POLYNOMIAL
      } else {
        crc_value >> 1
      }
    }
    table[table_index] = crc_value
  }
  table
}

///|
/// Compute CRC-32 checksum for given byte array
pub fn crc32(bytes : Array[Byte], table? : Array[UInt]) -> UInt {
  // Initialize CRC to all 1 bits
  let mut crc : UInt = 0xFFFF_FFFFU

  // Use provided table or generate a new one
  let lookup_table = table.unwrap_or_else(fn() { generate_crc32_table() })
  for byte in bytes {
    let lookup_index = (crc ^ byte.to_uint()) & 0xFFU
    crc = (crc >> 8) ^ lookup_table[lookup_index.reinterpret_as_int()]
  }

  // Finalize by inverting all bits
  crc ^ 0xFFFF_FFFFU
}
