///|
pub struct BitReaderStream {
  fifo : Array[Byte]
  head : Int
  tail : Int
  cap : Int
  bit_buff : UInt64
  bit_cnt : UInt
}

///|
pub fn bit_reader() -> BitReaderStream {
  BitReaderStream::{
    fifo: [],
    head: 0,
    tail: 0,
    cap: 0,
    bit_buff: 0,
    bit_cnt: 0,
  }
}

///|
pub fn feed(_self : BitReaderStream, _input : Bytes) -> Int {
  0
}

///|
pub fn read_bit(_self : BitReaderStream, _n : UInt) -> Byte? {
  None
}

///|
pub fn align_to_byte(_self : BitReaderStream) -> Unit {

}

///|
pub fn can_read(_self : BitReaderStream) -> Bool {
  false
}

///|
pub fn byte_available(_self : BitReaderStream) -> Int {
  0
}

///|
pub fn take_bytes(_self : BitReaderStream) -> Bytes? {
  None
}
