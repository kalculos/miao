///|
/// ID or X
struct Holder[T] {
  id : Int
  value : T?
}

///|
pub fn[T] read_holder(
  buf : &@buffer.ByteSlice,
  read_value : (&@buffer.ByteSlice) -> T,
) -> Holder[T] raise {
  let id = read_varint(buf)
  let value = if id != 0 { Some(read_value(buf)) } else { None }
  { id, value }
}

///|
pub fn[T] write_holder(
  buf : &@buffer.ByteSlice,
  holder : Holder[T],
  write_value : (&@buffer.ByteSlice, T) -> Unit,
) -> Unit raise {
  write_varint(buf, holder.id)
  if holder.id != 0 {
    write_value(buf, holder.value.unwrap())
  }
}
