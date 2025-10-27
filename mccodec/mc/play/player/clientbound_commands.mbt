///|
/// Commands packet (0x10)
/// Declares available commands
struct CommandsS2C {
  nodes : Array[String] // Command node data (complex structure)
  root_index : Int // Index of root node
}
///|
impl @mc.Packet for CommandsS2C with clientbound(self) {
  true
}