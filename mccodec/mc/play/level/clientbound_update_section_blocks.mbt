///|
/// Update Section Blocks packet (0x4D)
/// Updates multiple blocks in section
struct UpdateSectionBlocksS2C {
  chunk_section_position : Int64 // Chunk section position
  blocks : Array[(Int16, Int)] // (Position, BlockState) pairs
}
///|
impl @mc.Packet for UpdateSectionBlocksS2C with clientbound(self) {
  true
}