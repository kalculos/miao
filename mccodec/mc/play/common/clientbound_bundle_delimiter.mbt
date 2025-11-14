///|
/// Bundle Delimiter packet (0x00)
/// Delimiter for bundle of packets to be processed together
pub(all) struct BundleDelimiterS2C {}
///|
pub impl @mc.Packet for BundleDelimiterS2C with clientbound(_) {
  true
}