///|
/// Award Statistics packet (0x03)
/// Updates client-side statistics
struct AwardStatisticsS2C {
  statistics : Array[(String, String, Int)] // (Category, Statistic, Value) entries
}
///|
impl @mc.Packet for AwardStatisticsS2C with clientbound(self) {
  true
}