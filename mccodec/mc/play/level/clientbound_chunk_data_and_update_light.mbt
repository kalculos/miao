///|
/// Chunk Data and Update Light packet (0x27)
/// Sends chunk data with lighting
struct ChunkDataAndUpdateLightS2C {
  chunk_x : Int // Chunk X
  chunk_z : Int // Chunk Z
  heightmaps : String // Heightmap NBT
  data : Array[Byte] // Chunk data
  block_entities : Array[String] // Block entity NBT
  sky_light_mask : Int64 // Sky light section mask
  block_light_mask : Int64 // Block light section mask  
  empty_sky_light_mask : Int64 // Empty sky light mask
  empty_block_light_mask : Int64 // Empty block light mask
  sky_light : Array[Array[Byte]] // Sky light arrays
  block_light : Array[Array[Byte]] // Block light arrays
}
///|
impl @mc.Packet for ChunkDataAndUpdateLightS2C with clientbound(self) {
  true
}