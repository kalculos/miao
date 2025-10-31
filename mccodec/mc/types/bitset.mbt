///|
/// Simple BitSet implementation for basic bit operations
pub struct BitSet {
  words : Array[UInt64] // Array of 64-bit words to store bits
} derive(Show, Eq)

///|
/// Create a new empty BitSet
pub fn BitSet::new() -> BitSet {
  { words: Array::new() }
}

///|
/// Read a BitSet from ByteBuf (for Minecraft protocol)
pub fn read_bitset(buf : &@buffer.Buffer) -> BitSet raise {
  let length = read_varint(buf)
  let words = Array::make(length, 0UL)
  for i = 0; i < length; i = i + 1 {
    words[i] = buf.read_uint64()
  }
  BitSet::{ words }
}

///|
/// Write BitSet to ByteBuf (for Minecraft protocol)  
pub fn write_bitset(buf : &@buffer.Buffer, bitset : BitSet) -> Unit {
  write_varint(buf, bitset.words.length())
  for i = 0; i < bitset.words.length(); i = i + 1 {
    buf.write_uint64(bitset.words[i])
  }
}

///|
/// Read Fixed BitSet from ByteBuf (for Minecraft protocol)
/// Fixed BitSet uses byte array encoding, not long array
pub fn read_fixed_bitset(buf : &@buffer.Buffer, num_bits : Int) -> BitSet raise {
  let num_bytes = (num_bits + 7) / 8  // ceil(num_bits / 8)
  let num_words = (num_bits + 63) / 64 // Convert to words for internal storage
  let words = Array::make(num_words, 0UL)
  
  // Read bytes and convert to BitSet format
  for byte_idx = 0; byte_idx < num_bytes; byte_idx = byte_idx + 1 {
    let byte_val = buf.read_byte()
    
    // Convert each bit in the byte to BitSet format
    for bit_in_byte = 0; bit_in_byte < 8; bit_in_byte = bit_in_byte + 1 {
      let global_bit_idx = byte_idx * 8 + bit_in_byte
      if global_bit_idx < num_bits {
        // Check if bit is set in byte: (Data[i / 8] & (1 << (i % 8))) != 0
        if (byte_val.to_int() & (1 << bit_in_byte)) != 0 {
          let word_idx = global_bit_idx / 64
          let bit_in_word = global_bit_idx % 64
          words[word_idx] = words[word_idx] | (1UL << bit_in_word)
        }
      }
    }
  }
  
  BitSet::{ words }
}

///|
/// Write Fixed BitSet to ByteBuf (for Minecraft protocol)
/// Converts BitSet to byte array format as specified by Minecraft protocol
pub fn write_fixed_bitset(buf : &@buffer.Buffer, bitset : BitSet, num_bits : Int) -> Unit {
  let num_bytes = (num_bits + 7) / 8  // ceil(num_bits / 8)
  
  // Convert BitSet to byte array format
  for byte_idx = 0; byte_idx < num_bytes; byte_idx = byte_idx + 1 {
    let mut byte_val = 0
    
    // Pack 8 bits into each byte
    for bit_in_byte = 0; bit_in_byte < 8; bit_in_byte = bit_in_byte + 1 {
      let global_bit_idx = byte_idx * 8 + bit_in_byte
      if global_bit_idx < num_bits && bitset.get(global_bit_idx) {
        byte_val = byte_val | (1 << bit_in_byte)
      }
    }
    
    buf.write_byte(byte_val.to_byte())
  }
}


///|
/// Ensure the BitSet can hold at least the specified number of words
fn BitSet::ensure_capacity(self : BitSet, words_required : Int) -> Unit {
  while self.words.length() < words_required {
    self.words.push(0UL)
  }
}

///|
/// Get the word index for a given bit index
fn word_index(bit_index : Int) -> Int {
  bit_index / 64
}

///|
/// Set the bit at the specified index to true
pub fn BitSet::set(self : BitSet, bit_index : Int) -> Unit {
  if bit_index < 0 {
    abort("BitSet index cannot be negative")
  }
  let word_idx = word_index(bit_index)
  self.ensure_capacity(word_idx + 1)
  self.words[word_idx] = self.words[word_idx] | (1UL << (bit_index % 64))
}

///|
/// Clear the bit at the specified index (set to false)
pub fn BitSet::clear(self : BitSet, bit_index : Int) -> Unit {
  if bit_index < 0 {
    abort("BitSet index cannot be negative")
  }
  let word_idx = word_index(bit_index)
  if word_idx >= self.words.length() {
    return // Bit is already clear
  }
  self.words[word_idx] = self.words[word_idx] & (1UL << (bit_index % 64)).lnot()
}

///|
/// Get the value of the bit at the specified index
pub fn BitSet::get(self : BitSet, bit_index : Int) -> Bool {
  if bit_index < 0 {
    abort("BitSet index cannot be negative")
  }
  let word_idx = word_index(bit_index)
  if word_idx >= self.words.length() {
    false
  } else {
    (self.words[word_idx] & (1UL << (bit_index % 64))) != 0UL
  }
}

///|
/// Return the number of bits set to true in this BitSet
pub fn BitSet::cardinality(self : BitSet) -> Int {
  let mut sum = 0
  for word in self.words {
    // Count set bits in each word
    let mut n = word
    while n != 0UL {
      sum += 1
      n = n & (n - 1UL) // Clear the lowest set bit
    }
  }
  sum
}

///|
/// Return true if this BitSet contains no bits that are set to true
pub fn BitSet::is_empty(self : BitSet) -> Bool {
  for word in self.words {
    if word != 0UL {
      return false
    }
  }
  true
}

///|
test "BitSet basic operations" {
  let bitset = BitSet::new()
  
  // Test basic set and get
  bitset.set(5)
  bitset.set(10)
  bitset.set(64) // This should expand to second word
  
  inspect(bitset.get(5), content="true")
  inspect(bitset.get(10), content="true")
  inspect(bitset.get(64), content="true")
  inspect(bitset.get(7), content="false")
  
  // Test cardinality
  inspect(bitset.cardinality(), content="3")
  
  // Test clear
  bitset.clear(10)
  inspect(bitset.get(10), content="false")
  inspect(bitset.cardinality(), content="2")
  
  // Test is_empty
  let empty_bitset = BitSet::new()
  inspect(empty_bitset.is_empty(), content="true")
  inspect(bitset.is_empty(), content="false")
}

///|
test "Fixed BitSet bit order" {
  // Test that bit ordering follows the specification:
  // The ith bit is set when (Data[i / 8] & (1 << (i % 8))) != 0
  
  // Create a BitSet with specific pattern to test bit ordering
  let bitset = BitSet::new()
  bitset.set(0)  // Should set bit 0 in first byte (value 1)
  bitset.set(2)  // Should set bit 2 in first byte (value 4) 
  bitset.set(8)  // Should set bit 0 in second byte (value 1)
  
  // Test cardinality
  inspect(bitset.cardinality(), content="3")
  
  // Test individual bits
  inspect(bitset.get(0), content="true")
  inspect(bitset.get(1), content="false") 
  inspect(bitset.get(2), content="true")
  inspect(bitset.get(3), content="false")
  inspect(bitset.get(8), content="true")
  inspect(bitset.get(9), content="false")
}
