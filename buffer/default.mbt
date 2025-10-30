///|
impl ByteReader with has_remaining(self) {
  self.remaining() > 0
}

///|
impl ByteReader with read_int(self) -> Int? {
  self
  .read_bytes(4)
  .map(bytes => (bytes[0].to_int() << 24) |
    (bytes[1].to_int() << 16) |
    (bytes[2].to_int() << 8) |
    bytes[3].to_int())
}

///|
impl ByteReader with read_int_le(self) -> Int? {
  self
  .read_bytes(4)
  .map(bytes => (bytes[3].to_int() << 24) |
    (bytes[2].to_int() << 16) |
    (bytes[1].to_int() << 8) |
    bytes[0].to_int())
}

///|
impl ByteReader with read_int16(self) -> Int16? {
  self
  .read_bytes(2)
  .map(bytes => ((bytes[0].to_int() << 8) | bytes[1].to_int()).to_int16())
}

///|
impl ByteReader with read_int16_le(self) -> Int16? {
  self
  .read_bytes(2)
  .map(bytes => ((bytes[1].to_int() << 8) | bytes[0].to_int()).to_int16())
}

///|
impl ByteReader with read_int64(self) -> Int64? {
  self
  .read_bytes(8)
  .map(bytes => (bytes[0].to_int64() << 56) |
    (bytes[1].to_int64() << 48) |
    (bytes[2].to_int64() << 40) |
    (bytes[3].to_int64() << 32) |
    (bytes[4].to_int64() << 24) |
    (bytes[5].to_int64() << 16) |
    (bytes[6].to_int64() << 8) |
    bytes[7].to_int64())
}

///|
impl ByteReader with read_int64_le(self) -> Int64? {
  self
  .read_bytes(8)
  .map(bytes => (bytes[7].to_int64() << 56) |
    (bytes[6].to_int64() << 48) |
    (bytes[5].to_int64() << 40) |
    (bytes[4].to_int64() << 32) |
    (bytes[3].to_int64() << 24) |
    (bytes[2].to_int64() << 16) |
    (bytes[1].to_int64() << 8) |
    bytes[0].to_int64())
}

///|
impl ByteReader with read_byte(self) -> Byte? {
  return self.read_bytes(1).map(it => it[0])
}

///|
impl ByteReader with read_uint(self) -> UInt? {
  self
  .read_bytes(4)
  .map(bytes => (bytes[0].to_uint() << 24) |
    (bytes[1].to_uint() << 16) |
    (bytes[2].to_uint() << 8) |
    bytes[3].to_uint())
}

///|
impl ByteReader with read_uint_le(self) -> UInt? {
  self
  .read_bytes(4)
  .map(bytes => (bytes[3].to_uint() << 24) |
    (bytes[2].to_uint() << 16) |
    (bytes[1].to_uint() << 8) |
    bytes[0].to_uint())
}

///|
impl ByteReader with read_uint16(self) -> UInt16? {
  self
  .read_bytes(2)
  .map(bytes => (bytes[0].to_uint16() << 8) | bytes[1].to_uint16())
}

///|
impl ByteReader with read_uint16_le(self) -> UInt16? {
  self
  .read_bytes(2)
  .map(bytes => (bytes[1].to_uint16() << 8) | bytes[0].to_uint16())
}

///|
impl ByteReader with read_uint64(self) -> UInt64? {
  self
  .read_bytes(8)
  .map(bytes => (bytes[0].to_uint64() << 56) |
    (bytes[1].to_uint64() << 48) |
    (bytes[2].to_uint64() << 40) |
    (bytes[3].to_uint64() << 32) |
    (bytes[4].to_uint64() << 24) |
    (bytes[5].to_uint64() << 16) |
    (bytes[6].to_uint64() << 8) |
    bytes[7].to_uint64())
}

///|
impl ByteReader with read_uint64_le(self) -> UInt64? {
  self
  .read_bytes(8)
  .map(bytes => (bytes[7].to_uint64() << 56) |
    (bytes[6].to_uint64() << 48) |
    (bytes[5].to_uint64() << 40) |
    (bytes[4].to_uint64() << 32) |
    (bytes[3].to_uint64() << 24) |
    (bytes[2].to_uint64() << 16) |
    (bytes[1].to_uint64() << 8) |
    bytes[0].to_uint64())
}

///|
impl ByteReader with read_float_le(self) -> Float? {
  return self.read_uint_le().map(it => it.reinterpret_as_float())
}

///|
impl ByteReader with read_float(self) -> Float? {
  return self.read_uint().map(it => it.reinterpret_as_float())
}

///|
impl ByteReader with read_double_le(self) -> Double? {
  return self.read_uint64_le().map(it => it.reinterpret_as_double())
}

///|
impl ByteReader with read_double(self) -> Double? {
  return self.read_uint64().map(it => it.reinterpret_as_double())
}

///|
impl ByteWriter with write_int(self, value : Int) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = ((value >> 24) & 0xFF).to_byte()
  bytes[1] = ((value >> 16) & 0xFF).to_byte()
  bytes[2] = ((value >> 8) & 0xFF).to_byte()
  bytes[3] = (value & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_int16(self, value : Int16) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = ((value >> 8) & 0xFF).to_byte()
  bytes[1] = (value & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_int64(self, value : Int64) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = ((value >> 56) & 0xFF).to_byte()
  bytes[1] = ((value >> 48) & 0xFF).to_byte()
  bytes[2] = ((value >> 40) & 0xFF).to_byte()
  bytes[3] = ((value >> 32) & 0xFF).to_byte()
  bytes[4] = ((value >> 24) & 0xFF).to_byte()
  bytes[5] = ((value >> 16) & 0xFF).to_byte()
  bytes[6] = ((value >> 8) & 0xFF).to_byte()
  bytes[7] = (value & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_uint(self, value : UInt) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = ((value >> 24) & 0xFF).to_byte()
  bytes[1] = ((value >> 16) & 0xFF).to_byte()
  bytes[2] = ((value >> 8) & 0xFF).to_byte()
  bytes[3] = (value & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_uint16(self, value : UInt16) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = ((value >> 8) & 0xFF).to_byte()
  bytes[1] = (value & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_uint64(self, value : UInt64) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = ((value >> 56) & 0xFF).to_byte()
  bytes[1] = ((value >> 48) & 0xFF).to_byte()
  bytes[2] = ((value >> 40) & 0xFF).to_byte()
  bytes[3] = ((value >> 32) & 0xFF).to_byte()
  bytes[4] = ((value >> 24) & 0xFF).to_byte()
  bytes[5] = ((value >> 16) & 0xFF).to_byte()
  bytes[6] = ((value >> 8) & 0xFF).to_byte()
  bytes[7] = (value & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_int_le(self, value : Int) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_int16_le(self, value : Int16) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_int64_le(self, value : Int64) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  bytes[4] = ((value >> 32) & 0xFF).to_byte()
  bytes[5] = ((value >> 40) & 0xFF).to_byte()
  bytes[6] = ((value >> 48) & 0xFF).to_byte()
  bytes[7] = ((value >> 56) & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_uint_le(self, value : UInt) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(4, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_uint16_le(self, value : UInt16) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(2, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_uint64_le(self, value : UInt64) -> Unit {
  let bytes : FixedArray[Byte] = FixedArray::make(8, 0)
  bytes[0] = (value & 0xFF).to_byte()
  bytes[1] = ((value >> 8) & 0xFF).to_byte()
  bytes[2] = ((value >> 16) & 0xFF).to_byte()
  bytes[3] = ((value >> 24) & 0xFF).to_byte()
  bytes[4] = ((value >> 32) & 0xFF).to_byte()
  bytes[5] = ((value >> 40) & 0xFF).to_byte()
  bytes[6] = ((value >> 48) & 0xFF).to_byte()
  bytes[7] = ((value >> 56) & 0xFF).to_byte()
  self.write_bytes(Bytes::from_fixedarray(bytes))
}

///|
impl ByteWriter with write_float_le(self, f) -> Unit {
  return self.write_uint_le(f.reinterpret_as_uint())
}

///|
impl ByteWriter with write_float(self, f) -> Unit {
  return self.write_uint(f.reinterpret_as_uint())
}

///|
impl ByteWriter with write_double_le(self, d) -> Unit {
  return self.write_uint64_le(d.reinterpret_as_uint64())
}

///|
impl ByteWriter with write_double(self, d) -> Unit {
  return self.write_uint64(d.reinterpret_as_uint64())
}

///|
impl ByteWriter with write_array(self, arr, off, len) -> Unit {
  guard arr.length() >= off + len
  for i = 0; i < len; i = i + 1 {
    self.write_byte(arr[off + i])
  }
}

///|
impl ByteReader with read_bytes_most(self, len) -> Bytes {
  if !self.has_remaining() {
    return Bytes::of([])
  }
  let buffer : Array[Byte] = Array::new(capacity=len)
  for i = 0; i < len; i = i + 1 {
    guard self.read_byte() is Some(byte) else { break }
    buffer.push(byte)
  }
  Bytes::from_array(buffer)
}

///|
impl ByteReader with read(self, dst, off, len) -> Int {
  guard dst.length() >= off + len else {
    return -1
  }
  for i = 0; i < len; i = i + 1 {
    guard self.read_byte() is Some(byte) else { return i }
    dst[off + i] = byte
  }else {
    i
  }
}

///|
impl ByteBuf with is_empty(self) -> Bool {
  self.len() == 0
}
