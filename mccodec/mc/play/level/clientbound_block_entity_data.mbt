///|
/// Block Entity Data packet (0x06)
/// Updates block entity data
struct BlockEntityDataS2C {
  location : (Int, Int, Int) // Block position
  entity_type : Int // Block entity type
  nbt_data : String // NBT data
}
///|
impl @mc.Packet for BlockEntityDataS2C with clientbound(self) {
  true
}