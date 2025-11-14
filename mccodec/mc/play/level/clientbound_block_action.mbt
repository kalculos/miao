///|
/// Block Action packet (0x07)
/// Triggers block action animation
pub(all) struct BlockActionS2C {
  location : (Int, Int, Int) // Block position
  action_id : Byte // Action ID
  action_param : Byte // Action parameter
  block_type : Int // Block type
}
///|
pub impl @mc.Packet for BlockActionS2C with clientbound(_) {
  true
}