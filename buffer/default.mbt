///|
pub fn &ByteSlice::read_bytes(self : &ByteSlice, len : Int) -> Bytes raise {
  let buf : FixedArray[Byte] = FixedArray::make(len, 0o0)
  guard self.readable_bytes() >= len else {
    raise fail("The bytebuf has been drained can couldn't read \{len} bytes.")
  }
  guard self.read(buf, 0, len) == len
  buf.unsafe_reinterpret_as_bytes()
}

///|
pub fn &ByteSlice::read_int(self : &ByteSlice) -> Int raise {
  let bytes = self.read_bytes(4)
  (bytes[0].to_int() << 24) |
  (bytes[1].to_int() << 16) |
  (bytes[2].to_int() << 8) |
  bytes[3].to_int()
}

///|
pub fn &ByteSlice::read_int_le(self : &ByteSlice) -> Int raise {
  let bytes = self.read_bytes(4)
  return (bytes[3].to_int() << 24) |
    (bytes[2].to_int() << 16) |
    (bytes[1].to_int() << 8) |
    bytes[0].to_int()
}

///|
pub fn &ByteSlice::read_int16(self : &ByteSlice) -> Int16 raise {
  let bytes = self.read_bytes(2)
  return ((bytes[0].to_int() << 8) | bytes[1].to_int()).to_int16()
}

///|
pub fn &ByteSlice::read_int16_le(self : &ByteSlice) -> Int16 raise {
  let bytes = self.read_bytes(2)
  return ((bytes[1].to_int() << 8) | bytes[0].to_int()).to_int16()
}

///|
pub fn &ByteSlice::read_int64(self : &ByteSlice) -> Int64 raise {
  let bytes = self.read_bytes(8)
  return (bytes[0].to_int64() << 56) |
    (bytes[1].to_int64() << 48) |
    (bytes[2].to_int64() << 40) |
    (bytes[3].to_int64() << 32) |
    (bytes[4].to_int64() << 24) |
    (bytes[5].to_int64() << 16) |
    (bytes[6].to_int64() << 8) |
    bytes[7].to_int64()
}

///|
pub fn &ByteSlice::read_int64_le(self : &ByteSlice) -> Int64 raise {
  let bytes = self.read_bytes(8)
  return (bytes[7].to_int64() << 56) |
    (bytes[6].to_int64() << 48) |
    (bytes[5].to_int64() << 40) |
    (bytes[4].to_int64() << 32) |
    (bytes[3].to_int64() << 24) |
    (bytes[2].to_int64() << 16) |
    (bytes[1].to_int64() << 8) |
    bytes[0].to_int64()
}

///|
pub fn &ByteSlice::read_uint(self : &ByteSlice) -> UInt raise {
  let bytes = self.read_bytes(4)
  return (bytes[0].to_uint() << 24) |
    (bytes[1].to_uint() << 16) |
    (bytes[2].to_uint() << 8) |
    bytes[3].to_uint()
}

///|
pub fn &ByteSlice::read_uint_le(self : &ByteSlice) -> UInt raise {
  let bytes = self.read_bytes(4)
  return (bytes[3].to_uint() << 24) |
    (bytes[2].to_uint() << 16) |
    (bytes[1].to_uint() << 8) |
    bytes[0].to_uint()
}

///|
pub fn &ByteSlice::read_uint16(self : &ByteSlice) -> UInt16 raise {
  let bytes = self.read_bytes(2)
  return (bytes[0].to_uint16() << 8) | bytes[1].to_uint16()
}

///|
pub fn &ByteSlice::read_uint16_le(self : &ByteSlice) -> UInt16 raise {
  let bytes = self.read_bytes(2)
  return (bytes[1].to_uint16() << 8) | bytes[0].to_uint16()
}

///|
pub fn &ByteSlice::read_uint64(self : &ByteSlice) -> UInt64 raise {
  let bytes = self.read_bytes(8)
  return (bytes[0].to_uint64() << 56) |
    (bytes[1].to_uint64() << 48) |
    (bytes[2].to_uint64() << 40) |
    (bytes[3].to_uint64() << 32) |
    (bytes[4].to_uint64() << 24) |
    (bytes[5].to_uint64() << 16) |
    (bytes[6].to_uint64() << 8) |
    bytes[7].to_uint64()
}

///|
pub fn &ByteSlice::read_uint64_le(self : &ByteSlice) -> UInt64 raise {
  let bytes = self.read_bytes(8)
  return (bytes[7].to_uint64() << 56) |
    (bytes[6].to_uint64() << 48) |
    (bytes[5].to_uint64() << 40) |
    (bytes[4].to_uint64() << 32) |
    (bytes[3].to_uint64() << 24) |
    (bytes[2].to_uint64() << 16) |
    (bytes[1].to_uint64() << 8) |
    bytes[0].to_uint64()
}

///|
pub fn &ByteSlice::read_float_le(self : &ByteSlice) -> Float raise {
  return self.read_uint_le().reinterpret_as_float()
}

///|
pub fn &ByteSlice::read_float(self : &ByteSlice) -> Float raise {
  return self.read_uint().reinterpret_as_float()
}

///|
pub fn &ByteSlice::read_double_le(self : &ByteSlice) -> Double raise {
  return self.read_uint64_le().reinterpret_as_double()
}

///|
pub fn &ByteSlice::read_double(self : &ByteSlice) -> Double raise {
  return self.read_uint64().reinterpret_as_double()
}

///|
pub fn &ByteSlice::write_int(self : &ByteSlice, value : Int) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = ((value >> 24) & 0xFF).to_byte()
  bytes[1] = ((value >> 16) & 0xFF).to_byte()
  bytes[2] = ((value >> 8) & 0xFF).to_byte()
  bytes[3] = (value & 0xFF).to_byte()
  guard self.write(bytes, 0, 4) == 4 else {
    raise fail("The slice is too small to append 4 bytes")
  }
}

///|
pub fn &ByteSlice::write_int16(self : &ByteSlice, value : Int16) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = ((value >> 8) & 0xFF).to_byte()
  bytes[1] = (value & 0xFF).to_byte()
  guard self.write(bytes, 0, 2) == 2 else {
    raise fail("The slice is too small to append 2 bytes")
  }
}

///|
pub fn &ByteSlice::write_int64(self : &ByteSlice, value : Int64) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = ((value >> 56) & 0xFF).to_byte()
  bytes[1] = ((value >> 48) & 0xFF).to_byte()
  bytes[2] = ((value >> 40) & 0xFF).to_byte()
  bytes[3] = ((value >> 32) & 0xFF).to_byte()
  bytes[4] = ((value >> 24) & 0xFF).to_byte()
  bytes[5] = ((value >> 16) & 0xFF).to_byte()
  bytes[6] = ((value >> 8) & 0xFF).to_byte()
  bytes[7] = (value & 0xFF).to_byte()
  guard self.write(bytes, 0, 8) == 8 else {
    raise fail("The slice is too small to append 8 bytes")
  }
}

///|
pub fn &ByteSlice::write_uint(self : &ByteSlice, value : UInt) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = ((value >> 24) & 0xFF).to_byte()
  bytes[1] = ((value >> 16) & 0xFF).to_byte()
  bytes[2] = ((value >> 8) & 0xFF).to_byte()
  bytes[3] = (value & 0xFF).to_byte()
  guard self.write(bytes, 0, 4) == 4 else {
    raise fail("The slice is too small to append 4 bytes")
  }
}

///|
pub fn &ByteSlice::write_uint16(
  self : &ByteSlice,
  value : UInt16,
) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = ((value >> 8) & 0xFF).to_byte()
  bytes[1] = (value & 0xFF).to_byte()
  guard self.write(bytes, 0, 2) == 2 else {
    raise fail("The slice is too small to append 2 bytes")
  }
}

///|
pub fn &ByteSlice::write_uint64(
  self : &ByteSlice,
  value : UInt64,
) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = ((value >> 56) & 0xFF).to_byte()
  bytes[1] = ((value >> 48) & 0xFF).to_byte()
  bytes[2] = ((value >> 40) & 0xFF).to_byte()
  bytes[3] = ((value >> 32) & 0xFF).to_byte()
  bytes[4] = ((value >> 24) & 0xFF).to_byte()
  bytes[5] = ((value >> 16) & 0xFF).to_byte()
  bytes[6] = ((value >> 8) & 0xFF).to_byte()
  bytes[7] = (value & 0xFF).to_byte()
  guard self.write(bytes, 0, 8) == 8 else {
    raise fail("The slice is too small to append 8 bytes")
  }
}

///|
pub fn &ByteSlice::write_int_le(self : &ByteSlice, value : Int) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  guard self.write(bytes, 0, 4) == 4 else {
    raise fail("The slice is too small to append 4 bytes")
  }
}

///|
pub fn &ByteSlice::write_int16_le(
  self : &ByteSlice,
  value : Int16,
) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  guard self.write(bytes, 0, 2) == 2 else {
    raise fail("The slice is too small to append 2 bytes")
  }
}

///|
pub fn &ByteSlice::write_int64_le(
  self : &ByteSlice,
  value : Int64,
) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  bytes[4] = ((value >> 32) & 0xFF).to_byte()
  bytes[5] = ((value >> 40) & 0xFF).to_byte()
  bytes[6] = ((value >> 48) & 0xFF).to_byte()
  bytes[7] = ((value >> 56) & 0xFF).to_byte()
  guard self.write(bytes, 0, 8) == 8 else {
    raise fail("The slice is too small to append 8 bytes")
  }
}

///|
pub fn &ByteSlice::write_uint_le(self : &ByteSlice, value : UInt) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  guard self.write(bytes, 0, 4) == 4 else {
    raise fail("The slice is too small to append 4 bytes")
  }
}

///|
pub fn &ByteSlice::write_uint16_le(
  self : &ByteSlice,
  value : UInt16,
) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  guard self.write(bytes, 0, 2) == 2 else {
    raise fail("The slice is too small to append 2 bytes")
  }
}

///|
pub fn &ByteSlice::write_uint64_le(
  self : &ByteSlice,
  value : UInt64,
) -> Unit raise {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  bytes[4] = ((value >> 32) & 0xFF).to_byte()
  bytes[5] = ((value >> 40) & 0xFF).to_byte()
  bytes[6] = ((value >> 48) & 0xFF).to_byte()
  bytes[7] = ((value >> 56) & 0xFF).to_byte()
  guard self.write(bytes, 0, 8) == 8 else {
    raise fail("The slice is too small to append 8 bytes")
  }
}

///|
pub fn &ByteSlice::write_float_le(self : &ByteSlice, f : Float) -> Unit raise {
  return self.write_uint_le(f.reinterpret_as_uint())
}

///|
pub fn &ByteSlice::write_float(self : &ByteSlice, f : Float) -> Unit raise {
  return self.write_uint(f.reinterpret_as_uint())
}

///|
pub fn &ByteSlice::write_double_le(self : &ByteSlice, d : Double) -> Unit raise {
  return self.write_uint64_le(d.reinterpret_as_uint64())
}

///|
pub fn &ByteSlice::write_double(self : &ByteSlice, d : Double) -> Unit raise {
  return self.write_uint64(d.reinterpret_as_uint64())
}

///|
pub fn &ByteSlice::write_array(
  self : &ByteSlice,
  arr : FixedArray[Byte],
  off : Int,
  len : Int,
) -> Int {
  guard arr.length() >= off + len
  let bytes = arr.unsafe_reinterpret_as_bytes()
  self.transfer_from(bytes[off:off + len])
}
