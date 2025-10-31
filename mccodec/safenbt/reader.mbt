///|
/// This reader utilitie does not track length limit. You must pass a length known bytebuf to it.
pub fn read_nbt_buf(
  buf : &@buffer.Buffer,
  max_depth? : Int = 512,
) -> &@buffer.ByteSlice raise {
  let stream_begin = buf.ridx()
  let mut depth = 0
  while true {
    let byte = buf.read_byte()
    if byte == @nbt.TypeEnd {
      depth -= 1
      guard depth >= 0 else {
        raise fail("NBTTag underflow at \{buf.ridx()}")
      }
      if depth == 0 {
        return buf.slice(stream_begin, buf.ridx())
      }
      continue
    }
    let name_len = buf.read_uint16()
    buf.skip_n(name_len.to_int())
    match byte {
      @nbt.TypeByte => buf.skip_n(1)
      @nbt.TypeLong | @nbt.TypeDouble => buf.skip_n(8)
      @nbt.TypeInt | @nbt.TypeFloat => buf.skip_n(4)
      @nbt.TypeShort => buf.skip_n(2)
      @nbt.TypeString => {
        let size = buf.read_uint16().to_int()
        buf.skip_n(size)
      }
      @nbt.TypeIntArray | @nbt.TypeLongArray | @nbt.TypeByteArray => {
        let size = match byte {
          @nbt.TypeIntArray => 4
          @nbt.TypeLongArray => 8
          @nbt.TypeByteArray => 1
          _ => raise fail("Invalid type: \{byte}")
        }
        let arrayLength = buf.read_int()
        buf.skip_n(arrayLength * size)
      }
      @nbt.TypeList => {
        buf.skip_n(1 + 4)
        //todo: depth support for lists
      }
      @nbt.TypeCompound => {
        depth += 1
        if depth > max_depth {
          raise fail("NBT depth limit exceeded at \{buf.ridx()}")
        }
      }
      _ => raise fail("Invalid type tag: \{byte}")
    }
  } else {
    raise fail("Impossible")
  }
}
