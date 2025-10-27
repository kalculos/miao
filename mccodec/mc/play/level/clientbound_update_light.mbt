///|
/// Update Light packet (0x2A)
/// Updates lighting information
struct UpdateLightS2C {
  chunk_x : Int // Chunk X
  chunk_z : Int // Chunk Z
  sky_light_mask : Int64 // Sky light mask
  block_light_mask : Int64 // Block light mask
  empty_sky_light_mask : Int64 // Empty sky light mask
  empty_block_light_mask : Int64 // Empty block light mask
  sky_light : Array[Array[Byte]] // Sky light data
  block_light : Array[Array[Byte]] // Block light data
}
///|
impl @mc.Packet for UpdateLightS2C with clientbound(self) {
  true
}