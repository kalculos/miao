pub(open) trait Packet {
  clientbound(Self) -> Bool
}

struct MinecraftClient { // states
///Once a Set Compression packet (with a non-negative threshold) is sent,
///  zlib compression is enabled for all following packets. The format of a packet changes slightly
///  to include the size of the uncompressed packet.
  priv mut compression: Bool
  
}