///|
/// Custom Report Details packet (0x81)
/// Custom crash report details
struct CustomReportDetailsS2C {
  details : Array[(String, String)] // (Title, Description) pairs
}
///|
impl @mc.Packet for CustomReportDetailsS2C with clientbound(self) {
  true
}