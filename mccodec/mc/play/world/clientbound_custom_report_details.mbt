///|
/// Custom Report Details packet (0x81)
/// Custom crash report details
pub(all) struct CustomReportDetailsS2C {
  details : Array[(String, String)] // (Title, Description) pairs
}
///|
pub impl @mc.Packet for CustomReportDetailsS2C with clientbound(_) {
  true
}