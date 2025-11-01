///|
pub struct StoredCopy {
  len : Int
}

///|
pub struct DynRead {
  filled : Int
  last_len : Byte
}

///|
pub struct DynReadCL {
  i : Int
}

///|
pub enum DeflateState {
  NeedBlockHeader
  StoredCopy(StoredCopy)
  FixedTablesReady
  DynReadCounts
  DynReadCL(DynReadCL)
  DynBuildCL
  DynReadLL(DynRead)
  DynReadDD(DynRead)
  DynBuildLLDD
  Lz77Loop
  FinishedStream
}

///|
pub struct DeflateStream {
  window : Array[Byte]
  window_postion : Int
  out_quene : Array[Byte]

  //
  bfinal_seen : Bool
  state : DeflateState

  //
  litlen : Huffman?
  dist : Huffman?

  //
  dyn_hlit : UInt
  dyn_hdist : UInt
  dyn_hclen : UInt
  cl_lens : Array[Byte]
  cl_tree : Huffman?
  ll_lens : Array[Byte]
  dd_lens : Array[Byte]
}

///|
pub fn deflate_stream() -> DeflateStream {
  DeflateStream::{
    window: [],
    window_postion: 0,
    out_quene: [],

    //
    bfinal_seen: false,
    state: NeedBlockHeader,

    //
    litlen: None,
    dist: None,

    //
    dyn_hlit: 0,
    dyn_hdist: 0,
    dyn_hclen: 0,
    cl_lens: [],
    cl_tree: None,
    ll_lens: [],
    dd_lens: [],
  }
}

///|
pub fn push_bits(_self : DeflateStream, _input : Array[Byte]) -> Int {
  0
}

///|
pub fn pull(_self : DeflateStream, _out : Array[Byte]) -> Int {
  0
}

///|
pub fn is_finished(_self : DeflateStream) -> Bool {
  false
}

///|
pub fn decode_step(_self : DeflateStream, _br : BitReaderStream) -> Bool {
  false
}
