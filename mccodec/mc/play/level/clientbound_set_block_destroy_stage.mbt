///|
/// Set Block Destroy Stage packet (0x05)
/// Shows block breaking animation
pub(all) struct SetBlockDestroyStageS2C {
  entity_id : Int // Entity breaking the block
  location : (Int, Int, Int) // Block position
  destroy_stage : Byte // Breaking stage (0-9, or -1 to remove)
}

///|
pub impl @mc.Packet for SetBlockDestroyStageS2C with clientbound(_) {
  true
}
