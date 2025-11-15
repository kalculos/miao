///|
/// Set Center Chunk packet (0x57)
/// Sets center chunk for loading
pub(all) struct SetCenterChunkS2C {
  chunk_x : Int // Center chunk X
  chunk_z : Int // Center chunk Z
}

///|
pub impl @mc.Packet for SetCenterChunkS2C with clientbound(_) {
  true
}
