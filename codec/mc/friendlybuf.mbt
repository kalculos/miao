// https://minecraft.wiki/w/Java_Edition_protocol/Packets#Type
// FOR COLLABORATORS: 不需要实现这个 trait,直接作为 ByteBuf 的方法编写就好（当扩展）
trait FriendlyByteBuf : @bytebuf.ByteBuf {
  read_varint(Self) -> Int = _
  read_varlong(Self) -> Int = _
  read_string(Self) -> String = _
  read_nbt(Self) -> @nbt.NBTTag = _
  // [T] read_array(Self, supplier: (&FriendlyByteBuf) -> T) -> Array[T] = _
}


