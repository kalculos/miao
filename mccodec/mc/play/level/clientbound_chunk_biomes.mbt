///|
/// Chunk Biomes packet (0x0D)
/// Updates biome data for chunks
pub(all) struct ChunkBiomesS2C {
  chunk_biomes : Array[(Int, Int, Array[Int])] // (ChunkX, ChunkZ, BiomeData) entries
}

///|
pub impl @mc.Packet for ChunkBiomesS2C with clientbound(_) {
  true
}
