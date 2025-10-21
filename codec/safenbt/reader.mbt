///|
/// A LimitedNBTReader is a filter reader that collects depth and length information
/// during a NBT stream. It returns a integral NBT block once a read.
pub struct LimitedNBTReader {
  max_depth : Int
  priv upstream : &@miao.Reader
  priv collector : &@bytebuf.ByteBuf
}

///|
pub fn LimitedNBTReader::new(
  max_bytes_len~ : Int,
  max_depth~ : Int,
  upstream~ : &@miao.Reader,
) -> LimitedNBTReader {
  guard max_bytes_len > 0
  guard max_depth > 0
  let buffer = @bytebuf.make_unpooled(256)
  let upstream = @miao.TeeReader::new(
    upstream,
    @miao.LimitedWriter::new(@miao.ByteBufWriter::new(buffer), max_bytes_len),
  )
  return LimitedNBTReader::{
    max_depth,
    upstream: upstream as &@miao.Reader,
    collector: buffer,
  }
}

///|
pub async fn LimitedNBTReader::read_nbt(
  self : LimitedNBTReader,
) -> &@bytebuf.ByteBuf {
  let buf = self.upstream
  let mut depth = 0
  while true {
    let byte : @nbt.NBTType = buf.read_byte()
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
    buf.read_exactly(name_len) |> ignore
    match byte {
      @nbt.TypeByte => buf.read_exactly(1) |> ignore
      @nbt.TypeLong | @nbt.TypeDouble => buf.read_exactly(8) |> ignore
      @nbt.TypeInt | @nbt.TypeFloat => buf.read_exactly(4) |> ignore
      @nbt.TypeShort => buf.read_exactly(2) |> ignore
      @nbt.TypeString => {
        let size = buf.read_buffer(2).read_uint16().unwrap().to_int()
        buf.read_exactly(size) |> ignore
      }
      @nbt.TypeIntArray | @nbt.TypeLongArray | @nbt.TypeByteArray => {
        let size = match byte {
          @nbt.TypeIntArray => 4
          @nbt.TypeLongArray => 8
          @nbt.TypeByteArray => 1
          _ => panic()
        }
        let arrayLength = buf.read_buffer(4).read_int().unwrap()
        buf.read_exactly(arrayLength * size) |> ignore
      }
      @nbt.TypeList => {
        let _type = buf.read_byte()
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
