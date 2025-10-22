///|
/// A LimitedNBTReader is a filter reader that collects depth and length information
/// during a NBT stream. It returns a integral NBT block once a read.
pub struct LimitedNBTReader {
  max_depth : Int
  priv upstream : &@io.Reader
  priv collector : &@bytebuf.ByteBuf
}

///|
pub fn LimitedNBTReader::new(
  max_bytes_len~ : Int,
  max_depth~ : Int,
  upstream~ : &@io.Reader,
) -> LimitedNBTReader {
  guard max_bytes_len > 0
  guard max_depth > 0
  let buffer = @bytebuf.make_unpooled(256)
  let upstream = @io.TeeReader::new(
    upstream,
    @io.LimitedWriter::new(@io.ByteBufWriter::new(buffer), max_bytes_len),
  )
  return LimitedNBTReader::{
    max_depth,
    upstream: upstream as &@io.Reader,
    collector: buffer,
  }
}

///|
pub async fn LimitedNBTReader::read_nbt(
  self : LimitedNBTReader,
) -> &@bytebuf.ByteBuf {
  let buf = self.upstream
  let mut depth = 0
  let reading_bytes : FixedArray[Byte] = FixedArray::make(1, 0)
  while true {
    guard buf.read(reading_bytes, 0, 1) == 1
    let byte : @nbt.NBTType = reading_bytes[0]
    if byte == @nbt.TypeEnd {
      depth -= 1
      guard depth >= 0 else {
        raise fail("NBTTag underflow at \{self.collector.position()}")
      }
      if depth == 0 {
        return self.collector
      }
      continue
    }
    let name_len = buf.read_buffer(2).read_uint16().unwrap().to_int() //todo optimize
    // we use read_exactly instead of skip_n to make sure that TeeReader has read those bytes.
    guard buf.read_buffer(name_len).len() == name_len
    match byte {
      @nbt.TypeByte => {
        guard buf.read_buffer(1).len() == 1
      }
      @nbt.TypeLong | @nbt.TypeDouble => {
        guard buf.read_buffer(8).len() == 8
      }
      @nbt.TypeInt | @nbt.TypeFloat => {
        guard buf.read_buffer(4).len() == 4
      }
      @nbt.TypeShort => {
        guard buf.read_buffer(2).len() == 2
      }
      @nbt.TypeString => {
        let size = buf.read_buffer(2).read_uint16().unwrap().to_int()
        guard buf.read_buffer(size).len() == size
      }
      @nbt.TypeIntArray | @nbt.TypeLongArray | @nbt.TypeByteArray => {
        let size = match byte {
          @nbt.TypeIntArray => 4
          @nbt.TypeLongArray => 8
          @nbt.TypeByteArray => 1
          _ => panic()
        }
        let arrayLength = buf.read_buffer(4).read_int().unwrap()
        guard buf.read_buffer(arrayLength * size).len() == arrayLength * size
      }
      @nbt.TypeList => {
        guard buf.read(reading_bytes, 0, 1) == 1
        let _type = reading_bytes[0]
        let len = buf.read_buffer(4).read_int().unwrap() // todo: check bnbt, is this signed or not?
        //todo: depth support for lists
        ignore(len)
      }
      @nbt.TypeCompound => {
        depth += 1
        if depth > self.max_depth {
          raise fail("NBT depth limit exceeded at \{self.collector.position()}")
        }
      }
      _ => raise fail("Invalid type tag: \{byte}")
    }
  } else {
    raise fail("Impossible")
  }
}
