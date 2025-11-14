///|
/// Chunk Batch Start packet (0x0C)  
/// Signals start of chunk batch
pub(all) struct ChunkBatchStartS2C {}
///|
pub impl @mc.Packet for ChunkBatchStartS2C with clientbound(_) {
  true
}