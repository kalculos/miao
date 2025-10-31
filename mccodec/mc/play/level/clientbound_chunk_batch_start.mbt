///|
/// Chunk Batch Start packet (0x0C)  
/// Signals start of chunk batch
struct ChunkBatchStartS2C {}
///|
impl @mc.Packet for ChunkBatchStartS2C with clientbound(self) {
  true
}