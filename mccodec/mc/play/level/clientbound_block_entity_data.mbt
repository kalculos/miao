///|
/// Block Entity Data packet (0x06)
/// Updates block entity data
pub(all) struct BlockEntityDataS2C {
  location : (Int, Int, Int) // Block position
  entity_type : Int // Block entity type
  nbt_data : String // NBT data
}
///|
pub impl @mc.Packet for BlockEntityDataS2C with clientbound(_) {
  true
}