///|
/// Tag Query Response packet (0x74)
/// Response to tag query
struct TagQueryResponseS2C {
  transaction_id : Int // Transaction ID
  nbt : String // NBT data
}
///|
impl @mc.Packet for TagQueryResponseS2C with clientbound(self) {
  true
}