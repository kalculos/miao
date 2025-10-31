///|
/// Test Instance Block Status packet (0x77)
/// Test block status update
struct TestInstanceBlockStatusS2C {
  location : (Int, Int, Int) // Block position
  block_state : Int // Block state ID
  block_entity_data : String? // Block entity NBT
}
///|
impl @mc.Packet for TestInstanceBlockStatusS2C with clientbound(self) {
  true
}