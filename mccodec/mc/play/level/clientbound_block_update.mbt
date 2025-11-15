///|
/// Block Update packet (0x08)
/// Updates a single block
pub(all) struct BlockUpdateS2C {
  location : (Int, Int, Int) // Block position
  block_id : Int // New block state ID
}

///|
pub impl @mc.Packet for BlockUpdateS2C with clientbound(_) {
  true
}
