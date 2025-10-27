///|
/// Bundle Delimiter packet (0x00)
/// Delimiter for bundle of packets to be processed together
struct BundleDelimiterS2C {}
///|
impl @mc.Packet for BundleDelimiterS2C with clientbound(self) {
  true
}