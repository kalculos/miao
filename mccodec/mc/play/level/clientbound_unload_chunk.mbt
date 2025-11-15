///|
/// Unload Chunk packet (0x21)
/// Unloads chunk from client
pub(all) struct UnloadChunkS2C {
  chunk_x : Int // Chunk X coordinate
  chunk_z : Int // Chunk Z coordinate
}

///|
pub impl @mc.Packet for UnloadChunkS2C with clientbound(_) {
  true
}
