///|
/// Map Data packet (0x2C)
/// Updates map display
struct MapDataS2C {
  map_id : Int // Map ID
  scale : Byte // Map scale
  locked : Bool // Map locked state
  tracking_position : Bool // Track position
  icons : Array[(Int, Byte, Byte, Byte, String?)] // (Type, X, Z, Direction, DisplayName)
  columns : Byte // Map columns
  rows : Byte? // Map rows (if columns > 0)
  x : Byte? // Map X offset (if columns > 0)
  z : Byte? // Map Z offset (if columns > 0)
  data : Array[Byte]? // Map pixel data (if columns > 0)
}
///|
impl @mc.Packet for MapDataS2C with clientbound(self) {
  true
}