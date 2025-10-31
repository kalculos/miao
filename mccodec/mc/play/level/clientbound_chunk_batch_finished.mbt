///|
/// Chunk Batch Finished packet (0x0B)
/// Signals end of chunk batch
struct ChunkBatchFinishedS2C {
  batch_size : Int // Number of chunks in batch
}
///|
impl @mc.Packet for ChunkBatchFinishedS2C with clientbound(self) {
  true
}