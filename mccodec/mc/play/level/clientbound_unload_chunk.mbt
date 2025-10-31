///|
/// Unload Chunk packet (0x21)
/// Unloads chunk from client
struct UnloadChunkS2C {
  chunk_x : Int // Chunk X coordinate
  chunk_z : Int // Chunk Z coordinate
}
///|
impl @mc.Packet for UnloadChunkS2C with clientbound(self) {
  true
}