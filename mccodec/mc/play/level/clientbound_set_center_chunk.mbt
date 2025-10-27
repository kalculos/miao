///|
/// Set Center Chunk packet (0x57)
/// Sets center chunk for loading
struct SetCenterChunkS2C {
  chunk_x : Int // Center chunk X
  chunk_z : Int // Center chunk Z
}
///|
impl @mc.Packet for SetCenterChunkS2C with clientbound(self) {
  true
}