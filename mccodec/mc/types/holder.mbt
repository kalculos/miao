///|
/// ID or X
struct Holder[T] {
  id : Int
  value : T?
}

///|
pub fn[T] read_holder(
  buf : &@buffer.Buffer,
  read_value : (&@buffer.Buffer) -> T,
) -> Holder[T] raise {
  let id = read_varint(buf)
  let value = if id != 0 { Some(read_value(buf)) } else { None }
  { id, value }
}

///|
pub fn[T] write_holder(
  buf : &@buffer.Buffer,
  holder : Holder[T],
  write_value : (&@buffer.Buffer, T) -> Unit,
) -> Unit {
  write_varint(buf, holder.id)
  if holder.id != 0 {
    write_value(buf, holder.value.unwrap())
  }
}
