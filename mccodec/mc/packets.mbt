///|
pub(open) trait Packet {
  clientbound(Self) -> Bool
  serialize(Self, &@buffer.Buffer) -> Unit raise = _
  deserialize(&@buffer.Buffer) -> Self raise = _
}

///|
impl Packet with serialize(self, buf : &@buffer.Buffer) {
  // Default implementation does nothing
}

///|
impl Packet with deserialize(buf : &@buffer.Buffer) {
   // Default implementation does nothing
   raise fail("Deserialize not implemented for this packet")
}

///|
struct MinecraftClient { // states
  ///Once a Set Compression packet (with a non-negative threshold) is sent,
  ///  zlib compression is enabled for all following packets. The format of a packet changes slightly
  ///  to include the size of the uncompressed packet.
  priv mut compression : Bool
  
  /// The threshold value for compression.
  /// Set by the Set Compression packet.
  priv mut threshold : Int
}
