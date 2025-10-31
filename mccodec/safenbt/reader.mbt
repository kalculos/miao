///|
/// This reader utilitie does not track length limit. You must pass a length known bytebuf to it.
pub fn read_nbt_buf(
  buf : &@buffer.Buffer,
  max_depth? : Int = 512,
) -> &@buffer.Buffer raise {
  let stream_begin = buf.position()
  let mut depth = 0
  while true {
    guard buf.read_byte() is Some(byte)
    if byte == @nbt.TypeEnd {
      depth -= 1
      guard depth >= 0 else {
        raise fail("NBTTag underflow at \{buf.position()}")
      }
      if depth == 0 {
        return buf.slice(stream_begin, buf.position())
      }
      continue
    }
    let name_len = buf.read_uint16().unwrap().to_int()
    // we use read_exactly instead of skip_n to make sure that TeeReader has read those bytes.
    guard buf.read_bytes(name_len) is Some(_)
    match byte {
      @nbt.TypeByte => buf.read_byte().unwrap() |> ignore
      @nbt.TypeLong | @nbt.TypeDouble => buf.read_bytes(8).unwrap() |> ignore
      @nbt.TypeInt | @nbt.TypeFloat => buf.read_bytes(4).unwrap() |> ignore
      @nbt.TypeShort => buf.read_uint().unwrap() |> ignore
      @nbt.TypeString => {
        let size = buf.read_uint16().unwrap().to_int()
        buf.read_bytes(size).unwrap() |> ignore
      }
      @nbt.TypeIntArray | @nbt.TypeLongArray | @nbt.TypeByteArray => {
        let size = match byte {
          @nbt.TypeIntArray => 4
          @nbt.TypeLongArray => 8
          @nbt.TypeByteArray => 1
          _ => panic()
        }
        let arrayLength = buf.read_int().unwrap()
        buf.read_bytes(arrayLength * size).unwrap() |> ignore
      }
      @nbt.TypeList => {
        let _type = buf.read_byte().unwrap()
        let len = buf.read_int().unwrap() // todo: check bnbt, is this signed or not?
        //todo: depth support for lists
        ignore(len)
      }
      @nbt.TypeCompound => {
        depth += 1
        if depth > max_depth {
          raise fail("NBT depth limit exceeded at \{buf.position()}")
        }
      }
      _ => raise fail("Invalid type tag: \{byte}")
    }
  } else {
    raise fail("Impossible")
  }
}
