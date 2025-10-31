///|
/// Block Update packet (0x08)
/// Updates a single block
struct BlockUpdateS2C {
  location : (Int, Int, Int) // Block position
  block_id : Int // New block state ID
}
///|
impl @mc.Packet for BlockUpdateS2C with clientbound(self) {
  true
}