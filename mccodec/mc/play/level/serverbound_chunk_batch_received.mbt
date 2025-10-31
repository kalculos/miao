///|
/// Chunk Batch Received packet (0x0A)
/// Acknowledges chunk batch receipt
struct ChunkBatchReceivedC2S {
  chunks_per_tick : Float // Desired chunks per tick
}

///|
impl @mc.Packet for ChunkBatchReceivedC2S with clientbound(self) {
  false
}

impl @mc.Packet for ChunkBatchReceivedC2S with serialize(
  self,
  buf : &@buffer.Buffer,
) {
  buf.write_float(self.chunks_per_tick)
}

impl @mc.Packet for ChunkBatchReceivedC2S with deserialize(
  buf : &@buffer.Buffer,
) {
  { chunks_per_tick: buf.read_float().unwrap() }
}

