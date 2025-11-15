///|
/// Chunk Batch Received packet (0x0A)
/// Acknowledges chunk batch receipt
pub(all) struct ChunkBatchReceivedC2S {
  chunks_per_tick : Float // Desired chunks per tick
}

///|
pub impl @mc.Packet for ChunkBatchReceivedC2S with clientbound(_) {
  false
}

///|
pub impl @mc.Packet for ChunkBatchReceivedC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_float(self.chunks_per_tick)
}

///|
pub impl @mc.Packet for ChunkBatchReceivedC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { chunks_per_tick: buf.read_float() }
}
