///|
/// Chunk Biomes packet (0x0D)
/// Updates biome data for chunks
struct ChunkBiomesS2C {
  chunk_biomes : Array[(Int, Int, Array[Int])] // (ChunkX, ChunkZ, BiomeData) entries
}
///|
impl @mc.Packet for ChunkBiomesS2C with clientbound(self) {
  true
}