///|
/// The threshold of switching resizing strategy from exponent to linear.
/// The idea is taken from Netty.
const THRESH : Int = 4 * 1024 * 1024

///|
let _EMPTY : FixedArray[Byte] = [0]

///|
pub struct HeapByteBuf {
  priv mut array : Ref[FixedArray[Byte]]
  priv mut ridx: Int
  priv mut widx: Int
}
